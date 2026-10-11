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

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    private static final int MINUTOS_SESION = 30;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

     
        String tipoDocumento = request.getParameter("tipoDocumento");
        String numeroDocumento = request.getParameter("numeroDocumento");
        String password = request.getParameter("password");

        if (tipoDocumento == null || numeroDocumento == null || password == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }
        numeroDocumento = numeroDocumento.trim();

        try (Connection con = ConexionDB.conectar()) {

            if (con == null) {
                response.sendRedirect("login.jsp?error=2");
                return;
            }

            String[] paciente = buscarFila(con,
                    "SELECT numero_documento FROM paciente "
                    + "WHERE numero_documento = ? AND tipo_documento = ? AND BINARY password = ?",
                    numeroDocumento, tipoDocumento, password);

            if (paciente != null) {
                HttpSession sesion = nuevaSesion(request, "PACIENTE");
                sesion.setAttribute("usuarioDni", paciente[0]); 
                response.sendRedirect("panel_paciente.jsp");
                return;
            }

            String[] medico = buscarFila(con,
                    "SELECT id, nombre FROM medico "
                    + "WHERE numero_documento = ? AND tipo_documento = ? AND BINARY password = ?",
                    numeroDocumento, tipoDocumento, password);

            if (medico != null) {
                HttpSession sesion = nuevaSesion(request, "MEDICO");
                sesion.setAttribute("medicoId", Integer.valueOf(medico[0]));
                sesion.setAttribute("medicoNombre", medico[1]);
                response.sendRedirect("panel_medico.jsp");
                return;
            }

           
            String[] admin = buscarFila(con,
                    "SELECT usuario, nombre FROM administrador "
                    + "WHERE usuario = ? AND BINARY password = ?",
                    numeroDocumento, password);

            if (admin != null) {
                HttpSession sesion = nuevaSesion(request, "ADMIN");
                sesion.setAttribute("adminUsuario", admin[0]);
                sesion.setAttribute("adminNombre", admin[1]);
                response.sendRedirect("panel_admin.jsp");
                return;
            }


            response.sendRedirect("login.jsp?error=1");

        } catch (SQLException e) {
            e.printStackTrace(); 
            response.sendRedirect("login.jsp?error=2");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }


    private String[] buscarFila(Connection con, String sql, String... params) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setString(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                int columnas = rs.getMetaData().getColumnCount();
                String[] fila = new String[columnas];
                for (int i = 0; i < columnas; i++) {
                    fila[i] = rs.getString(i + 1);
                }
                return fila;
            }
        }
    }


    private HttpSession nuevaSesion(HttpServletRequest request, String rol) {
        HttpSession anterior = request.getSession(false);
        if (anterior != null) {
            anterior.invalidate();
        }
        HttpSession sesion = request.getSession(true);
        sesion.setAttribute("rol", rol);
        sesion.setMaxInactiveInterval(MINUTOS_SESION * 60);
        return sesion;
    }
}