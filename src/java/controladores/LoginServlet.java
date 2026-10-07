package controladores;

import Conexion.ConexionDB;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // Capturar credenciales del login
        String tipoDocumento = request.getParameter("tipoDocumento");
        String numeroDocumento = request.getParameter("numeroDocumento");
        String password = request.getParameter("password"); // Nota: En este punto inicial validaremos la existencia del usuario

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = ConexionDB.conectar();
            
            // Consultamos si el paciente con ese tipo y número existe en la base de datos
            String sql = "SELECT * FROM pacientes WHERE numero_documento = ? AND tipo_documento = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, numeroDocumento);
            ps.setString(2, tipoDocumento);
            
            rs = ps.executeQuery();

            if (rs.next()) {
                // 1. Capturamos el número de documento real desde la base de datos
                String dniLogueado = rs.getString("numero_documento");
                
                // 2. Creamos la sesión del navegador
                javax.servlet.http.HttpSession session = request.getSession();
                
                // 3. Guardamos el DNI dentro de la sesión con el nombre "usuarioDni"
                session.setAttribute("usuarioDni", dniLogueado);
                // ¡Usuario encontrado! Redirigimos directamente al Panel del Paciente
                response.sendRedirect("panel_paciente.jsp"); 
            } else {
                // Usuario no registrado o datos incorrectos
                out.println("<!DOCTYPE html><html><body style='font-family:Arial; text-align:center; padding-top:50px;'>");
                out.println("<h1 style='color:#c0392b;'>Error de Autenticación</h1>");
                out.println("<p>El documento ingresado no se encuentra registrado en el sistema.</p>");
                out.println("<br><a href='login.jsp'>Volver a intentar</a>");
                out.println("</body></html>");
            }

        } catch (SQLException e) {
            out.println("<h3>Error en el proceso de Login: " + e.getMessage() + "</h3>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException ex) {
                System.out.println("Error al cerrar recursos: " + ex.getMessage());
            }
        }
    }
}
