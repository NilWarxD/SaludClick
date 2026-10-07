package controladores;

import Conexion.ConexionDB; // Tu clase de conexión
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ProgramarCitaServlet", urlPatterns = {"/ProgramarCitaServlet"})
public class ProgramarCitaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // 1. Capturar los datos seleccionados por el paciente en el formulario web
        // Reemplaza la captura antigua por esta versión limpia
        String numeroDocumento = request.getParameter("numeroDocumento");
        String idMedico = request.getParameter("idMedico"); // <-- Captura el ID dinámico del médico
        String fecha = request.getParameter("fecha");
        String hora = request.getParameter("hora");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = ConexionDB.conectar();
            
            // 2. Sentencia SQL para insertar la nueva cita en MySQL Workbench
            // Nota: Se adaptó para registrar los campos obligatorios de tu tabla de citas
            // Reemplazamos 'dni_paciente' por 'numero_documento'
            String sql = "INSERT INTO citas (numero_documento, id_medico, fecha_cita, hora_cita, estado) VALUES (?, ?, ?, ?, 'Programada')";

            ps = con.prepareStatement(sql);
            ps.setString(1, numeroDocumento);
            ps.setInt(2, Integer.parseInt(idMedico)); // Convierte el texto del ID a número entero
            ps.setString(3, fecha);
            ps.setString(4, hora);

            int resultado = ps.executeUpdate();

            // 3. Respuesta visual de éxito accesible
            out.println("<!DOCTYPE html>");
            out.println("<html lang='es'>");
            out.println("<head><title>Cita Confirmada</title></head>");
            out.println("<body style='font-family:Arial, sans-serif; text-align:center; padding-top:60px; background-color:#f1f5f9;'>");
            out.println("<div style='max-width:500px; background:white; padding:30px; border-radius:12px; margin:0 auto; box-shadow:0 4px 6px rgba(0,0,0,0.05);'>");
            
            if (resultado > 0) {
            out.println("<h1 style='color:#10b981;'>✔ ¡Cita Programada con Éxito!</h1>");
            out.println("<p style='color:#475569; margin-top:10px;'>Su cita médica ha sido registrada correctamente de forma automática en el establecimiento seleccionado.</p>");
            out.println("<p style='color:#64748b; font-size:0.9rem;'>Fecha: " + fecha + " | Hora: " + hora + "</p>");
            }
            else {
                out.println("<h1 style='color:#ef4444;'>❌ Error al Agendar</h1>");
                out.println("<p style='color:#475569;'>No se pudo procesar la reserva en este momento.</p>");
            }
            
            out.println("<br><br><a href='panel_paciente.jsp' style='padding:12px 24px; background:#1e3a8a; color:white; text-decoration:none; border-radius:8px; font-weight:bold;'>Volver al Panel</a>");
            out.println("</div></body></html>");

        } catch (SQLException e) {
            out.println("<h3>Error en la base de datos al guardar la cita: " + e.getMessage() + "</h3>");
            out.println("<br><a href='panel_paciente.jsp'>Volver</a>");
        } catch (NumberFormatException e) {
            out.println("<h3>Error en el formato de los datos: Seleccione un establecimiento válido.</h3>");
            out.println("<br><a href='panel_paciente.jsp'>Volver</a>");
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException ex) {
                System.out.println("Error al cerrar recursos: " + ex.getMessage());
            }
        }
    }
}
