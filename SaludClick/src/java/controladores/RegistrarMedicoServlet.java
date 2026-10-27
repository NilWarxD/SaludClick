package controladores;

import Conexion.ConexionDB;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "RegistrarMedicoServlet", urlPatterns = {"/RegistrarMedicoServlet"})
public class RegistrarMedicoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        HttpSession sesion = request.getSession(false);
        if (sesion == null || !"ADMIN".equals(sesion.getAttribute("rol"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        
        request.setCharacterEncoding("UTF-8");


        String tipoDocumento = limpiar(request.getParameter("tipoDocumento"));
        String numeroDocumento = limpiar(request.getParameter("numeroDocumento"));
        String nombre = limpiar(request.getParameter("nombre"));
        String especialidad = limpiar(request.getParameter("especialidad"));
        String idEstablecimientoTxt = limpiar(request.getParameter("idEstablecimiento"));
        String email = limpiar(request.getParameter("email"));
        String telefono = limpiar(request.getParameter("telefono"));
        String password = request.getParameter("password"); // sin recortar espacios


        if (nombre.isEmpty() || especialidad.isEmpty() || numeroDocumento.isEmpty()
                || password == null || password.isEmpty()
                || nombre.length() > 100 || especialidad.length() > 100) {
            response.sendRedirect("registro_medico.jsp?error=1");
            return;
        }

        boolean tipoValido = tipoDocumento.equals("DNI") || tipoDocumento.equals("CE")
                || tipoDocumento.equals("PASAPORTE");
        boolean documentoValido = tipoDocumento.equals("DNI")
                ? numeroDocumento.matches("\\d{8}")
                : numeroDocumento.matches("[A-Za-z0-9]{6,20}");
        if (!tipoValido || !documentoValido) {
            response.sendRedirect("registro_medico.jsp?error=6");
            return;
        }

        if (password.length() < 6) {
            response.sendRedirect("registro_medico.jsp?error=5");
            return;
        }

        if ((!email.isEmpty() && !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"))
                || (!telefono.isEmpty() && !telefono.matches("\\+?\\d{6,15}"))
                || email.length() > 100) {
            response.sendRedirect("registro_medico.jsp?error=7");
            return;
        }

        int idEstablecimiento;
        try {
            idEstablecimiento = Integer.parseInt(idEstablecimientoTxt);
        } catch (NumberFormatException e) {
            response.sendRedirect("registro_medico.jsp?error=2");
            return;
        }

        try (Connection con = ConexionDB.conectar()) {

            if (con == null) {
                response.sendRedirect("registro_medico.jsp?error=3");
                return;
            }

            
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT 1 FROM paciente WHERE numero_documento = ?")) {
                ps.setString(1, numeroDocumento);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("registro_medico.jsp?error=4");
                        return;
                    }
                }
            }

            String sql = "INSERT INTO medico "
                    + "(tipo_documento, numero_documento, nombre, especialidad, "
                    + "id_establecimiento, email, telefono, password) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, tipoDocumento);
                ps.setString(2, numeroDocumento);
                ps.setString(3, nombre);
                ps.setString(4, especialidad);
                ps.setInt(5, idEstablecimiento);
                ps.setString(6, email.isEmpty() ? null : email);
                ps.setString(7, telefono.isEmpty() ? null : telefono);
                ps.setString(8, password); 

                int resultado = ps.executeUpdate();
                response.sendRedirect(resultado > 0
                        ? "registro_medico.jsp?ok=1"
                        : "registro_medico.jsp?error=3");
            }

        } catch (SQLException e) {
            e.printStackTrace(); 
            if (e.getErrorCode() == 1062) {          
                response.sendRedirect("registro_medico.jsp?error=4");
            } else if (e.getErrorCode() == 1452) {   
                response.sendRedirect("registro_medico.jsp?error=2");
            } else {
                response.sendRedirect("registro_medico.jsp?error=3");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("registro_medico.jsp");
    }


    private static String limpiar(String texto) {
        return texto == null ? "" : texto.trim();
    }
}