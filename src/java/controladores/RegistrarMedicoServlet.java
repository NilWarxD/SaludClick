package controladores;

import Conexion.ConexionDB;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RegistrarMedicoServlet", urlPatterns = {"/RegistrarMedicoServlet"})
public class RegistrarMedicoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Necesario para que las tildes y la ñ (Pérez, Peña) se guarden bien
        request.setCharacterEncoding("UTF-8");

        // 1. Capturar datos del formulario
        String nombre = request.getParameter("nombre");
        String especialidad = request.getParameter("especialidad");
        String idEstablecimientoTxt = request.getParameter("idEstablecimiento");

        // 2. Validar que no lleguen vacíos
        if (nombre == null || nombre.trim().isEmpty()
                || especialidad == null || especialidad.trim().isEmpty()) {
            response.sendRedirect("registro_medico.jsp?error=1");
            return;
        }

        int idEstablecimiento;
        try {
            idEstablecimiento = Integer.parseInt(idEstablecimientoTxt);
        } catch (NumberFormatException e) {
            response.sendRedirect("registro_medico.jsp?error=2");
            return;
        }

        // 3. Insertar en la base de datos
        String sql = "INSERT INTO medico (nombre, especialidad, id_establecimiento) VALUES (?, ?, ?)";

        try (Connection con = ConexionDB.conectar()) {

            if (con == null) {
                response.sendRedirect("registro_medico.jsp?error=3");
                return;
            }

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, nombre.trim());
                ps.setString(2, especialidad.trim());
                ps.setInt(3, idEstablecimiento);

                int resultado = ps.executeUpdate();

                if (resultado > 0) {
                    response.sendRedirect("registro_medico.jsp?ok=1");
                } else {
                    response.sendRedirect("registro_medico.jsp?error=3");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace(); // el detalle queda en la consola, no en la página
            response.sendRedirect("registro_medico.jsp?error=3");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("registro_medico.jsp");
    }
}