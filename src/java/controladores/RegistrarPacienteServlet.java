package controladores;

import Conexion.ConexionDB; // Tu clase de conexión
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

// IMPORTACIONES USANDO JAVAX (Tu entorno estable)
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RegistrarPacienteServlet", urlPatterns = {"/RegistrarPacienteServlet"})
public class RegistrarPacienteServlet extends HttpServlet {

        @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // 1. Capturar los parámetros tradicionales + la nueva contraseña
        String tipoDocumento = request.getParameter("tipoDocumento");
        String numeroDocumento = request.getParameter("numeroDocumento");
        String nombres = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String telefono = request.getParameter("telefono");
        String email = request.getParameter("email");
        String password = request.getParameter("password"); // <-- Capturamos la clave

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = ConexionDB.conectar();
            
            // 2. Agregamos el campo 'password' y un signo de interrogación (?) más al SQL
            String sql = "INSERT INTO pacientes (numero_documento, tipo_documento, nombres, apellidos, telefono, email, password) VALUES (?, ?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, numeroDocumento);
            ps.setString(2, tipoDocumento);
            ps.setString(3, nombres);
            ps.setString(4, apellidos);
            ps.setString(5, telefono);
            ps.setString(6, email);
            ps.setString(7, password); // <-- Insertamos la clave en la posición 7

            int resultado = ps.executeUpdate();

            out.println("<!DOCTYPE html>");
            out.println("<html lang='es'>");
            out.println("<head><title>Resultado del Registro</title></head>");           
            out.println("<body style='font-family:Arial, sans-serif; text-align:center; padding-top:50px; background-color:#f4f7f6;'>");
            if (resultado > 0) {
                out.println("<h1 style='color:#27ae60;'>¡Paciente registrado con éxito en SaludClick!</h1>");
                out.println("<p style='color:#555;'>Ya puedes iniciar sesión con tu documento y tu nueva contraseña.</p>");
            } else {
                out.println("<h1 style='color:#c0392b;'>Error al intentar registrar al paciente.</h1>");
            }
            out.println("<br><br><a href='login.jsp' style='padding:12px 24px; background:#2563eb; color:white; text-decoration:none; border-radius:8px; font-weight:bold;'>Ir a Iniciar Sesión</a>");
            out.println("</body>");
            out.println("</html>");

        } catch (SQLException e) {
            out.println("<!DOCTYPE html><html><body>");
            out.println("<h3 style='color:red;'>Error de Base de Datos: " + e.getMessage() + "</h3>");
            out.println("<br><a href='registro_paciente.jsp'>Volver</a>");
            out.println("</body></html>");
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException ex) {
                System.out.println("Error al cerrar recursos: " + ex.getMessage());
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("registro_paciente.jsp");
    }
}
