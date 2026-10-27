<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.util.*, java.time.format.DateTimeFormatter, Conexion.ConexionDB"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    private static String claseEstado(String estado) {
        if (estado == null) return "est-otro";
        String e = estado.toLowerCase(Locale.ROOT);
        if (e.startsWith("program") || e.startsWith("confirm")) return "est-programada";
        if (e.startsWith("atend")) return "est-atendida";
        if (e.startsWith("cancel")) return "est-cancelada";
        return "est-otro";
    }

    private static String tabla(List<String[]> filas, boolean conFecha) {
        StringBuilder sb = new StringBuilder();
        sb.append("<div class=\"tabla-wrap\"><table><thead><tr>");
        if (conFecha) sb.append("<th>Fecha</th>");
        sb.append("<th>Hora</th><th>Paciente</th><th>Documento</th><th>Teléfono</th><th>Estado</th><th>Acción</th>");
        sb.append("</tr></thead><tbody>");
        for (String[] f : filas) {
            sb.append("<tr>");
            if (conFecha) sb.append("<td>").append(esc(f[0])).append("</td>");
            sb.append("<td><strong>").append(esc(f[1])).append("</strong></td>");
            sb.append("<td>").append(esc(f[2])).append("</td>");
            sb.append("<td>").append(esc(f[3])).append("</td>");
            sb.append("<td>").append(f[4] == null || f[4].isEmpty() ? "—" : esc(f[4])).append("</td>");
            sb.append("<td><span class=\"estado ").append(claseEstado(f[5])).append("\">")
              .append(esc(f[5])).append("</span></td>");
            sb.append("<td><div class=\"acciones\">");
            sb.append("<a class=\"btn-consulta\" href=\"registrar_consulta.jsp?citaId=")
              .append(esc(f[6])).append("\">Registrar consulta</a>");
            sb.append("<a class=\"btn-ficha\" href=\"ficha_medica.jsp?citaId=")
              .append(esc(f[6])).append("\">Ficha médica</a>");
            sb.append("</div></td>");
            sb.append("</tr>");
        }
        sb.append("</tbody></table></div>");
        return sb.toString();
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Integer medicoId = (Integer) session.getAttribute("medicoId");
    if (!"MEDICO".equals(session.getAttribute("rol")) || medicoId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombreMedico = (String) session.getAttribute("medicoNombre");
    String especialidad = "";
    String establecimiento = "";
    List<String[]> citasHoy = new ArrayList<>();
    List<String[]> citasProximas = new ArrayList<>();
    boolean errorCarga = false;
    DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    try (Connection con = ConexionDB.conectar()) {
        if (con == null) {
            throw new SQLException("No se pudo conectar con la base de datos.");
        }

        String sqlMedico = "SELECT m.nombre, m.especialidad, e.nombre AS establecimiento "
                + "FROM medico m LEFT JOIN establecimiento e ON e.id = m.id_establecimiento "
                + "WHERE m.id = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlMedico)) {
            ps.setInt(1, medicoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    nombreMedico = rs.getString("nombre");
                    especialidad = rs.getString("especialidad");
                    establecimiento = rs.getString("establecimiento");
                }
            }
        }

        String sqlCitas = "SELECT c.id AS cita_id, c.fecha_cita, c.hora_cita, c.estado, "
                + "(c.fecha_cita = CURDATE()) AS es_hoy, "
                + "p.nombre, p.apellido, p.numero_documento, p.telefono "
                + "FROM cita c JOIN paciente p ON p.numero_documento = c.numero_documento "
                + "WHERE c.id_medico = ? AND c.fecha_cita >= CURDATE() "
                + "AND LOWER(c.estado) NOT LIKE 'cancel%' "
                + "AND LOWER(c.estado) NOT LIKE 'atend%' "
                + "ORDER BY c.fecha_cita, c.hora_cita";

        try (PreparedStatement ps = con.prepareStatement(sqlCitas)) {
            ps.setInt(1, medicoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String hora = rs.getString("hora_cita");
                    if (hora != null && hora.length() >= 5) hora = hora.substring(0, 5);
                    java.sql.Date fechaSql = rs.getDate("fecha_cita");
                    String fecha = fechaSql != null ? fechaSql.toLocalDate().format(formatoFecha) : "";
                    String nombrePaciente = rs.getString("nombre") + " " + rs.getString("apellido");
                    String telefonoPaciente = rs.getString("telefono");

                    String[] fila = {
                        fecha,
                        hora,
                        nombrePaciente,
                        rs.getString("numero_documento"),
                        telefonoPaciente,
                        rs.getString("estado"),
                        String.valueOf(rs.getInt("cita_id"))
                    };

                    if (rs.getBoolean("es_hoy")) citasHoy.add(fila);
                    else citasProximas.add(fila);
                }
            }
        }
    } catch (SQLException e) {
        application.log("Error al cargar el panel del médico", e);
        errorCarga = true;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Panel del médico</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }
        body { display: flex; min-height: 100vh; background: #f1f5f9; color: #1e293b; }
        .sidebar { width: 250px; background: #1e3a8a; padding: 24px 14px; display: flex; flex-direction: column; flex-shrink: 0; }
        .sidebar img { width: 150px; display: block; margin: 0 auto 28px; }
        .sidebar .item { display: block; padding: 12px 14px; border-radius: 8px; color: #dbeafe; text-decoration: none; font-weight: 600; margin-bottom: 6px; }
        .sidebar .item.activo, .sidebar .item:hover { background: #1a56db; color: #fff; }
        .sidebar .salir { margin-top: auto; background: #b91c1c; color: #fff; text-align: center; padding: 12px; border-radius: 8px; text-decoration: none; font-weight: 700; }
        .sidebar .salir:hover { background: #991b1b; }
        .contenido { flex: 1; padding: 32px 40px; min-width: 0; }
        .contenido h1 { font-size: 2rem; margin-bottom: 6px; }
        .contenido .rol { color: #64748b; margin-bottom: 28px; padding-bottom: 18px; border-bottom: 1px solid #e2e8f0; }
        .resumen { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 30px; }
        .dato { background: #fff; border-radius: 12px; padding: 18px 24px; border-left: 5px solid #1a56db; min-width: 190px; box-shadow: 0 2px 8px rgba(15,23,42,.04); }
        .dato strong { display: block; font-size: 2.1rem; color: #1e3a8a; line-height: 1.1; }
        .dato span { color: #64748b; }
        .bloque { background: #fff; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(15,23,42,.04); }
        .bloque h2 { font-size: 1.25rem; color: #1e3a8a; margin-bottom: 14px; }
        .vacio { color: #64748b; padding: 6px 0; }
        .tabla-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; font-size: .95rem; color: #475569; padding: 10px 12px; border-bottom: 2px solid #e2e8f0; white-space: nowrap; }
        td { padding: 12px; border-bottom: 1px solid #f1f5f9; white-space: nowrap; }
        .estado { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: .9rem; font-weight: 700; }
        .est-programada { background: #dbeafe; color: #1e40af; }
        .est-atendida { background: #dcfce7; color: #166534; }
        .est-cancelada { background: #fee2e2; color: #991b1b; }
        .est-otro { background: #e2e8f0; color: #334155; }
        .btn-consulta { display: inline-block; padding: 8px 12px; background: #10b981; color: #fff; text-decoration: none; border-radius: 7px; font-size: 13px; font-weight: 700; }
        .btn-consulta:hover { background: #059669; }
        .acciones { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .btn-ficha { display: inline-block; padding: 8px 12px; background: #2563eb; color: #fff; text-decoration: none; border-radius: 7px; font-size: 13px; font-weight: 700; }
        .btn-ficha:hover { background: #1d4ed8; }
        .mensaje-error { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 10px; padding: 14px 18px; margin-bottom: 22px; font-weight: 600; }
        .mensaje-ok { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; border-radius: 10px; padding: 14px 18px; margin-bottom: 22px; font-weight: 600; }
        @media (max-width: 800px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; flex-direction: row; flex-wrap: wrap; align-items: center; gap: 8px; padding: 14px; }
            .sidebar img { width: 110px; margin: 0 12px 0 0; }
            .sidebar .item { margin-bottom: 0; }
            .sidebar .salir { margin-top: 0; margin-left: auto; padding: 10px 16px; }
            .contenido { padding: 24px 18px; }
        }
    </style>
</head>
<body>
    <nav class="sidebar">
        <img src="img/logoblanco.png" alt="SaludClick">
        <a class="item activo" href="panel_medico.jsp">Mis citas</a>
        <a class="salir" href="LogoutServlet">Cerrar sesión</a>
    </nav>

    <main class="contenido">
        <h1>Bienvenido(a), <%= esc(nombreMedico) %></h1>
        <p class="rol"><%= esc(especialidad) %> en <%= esc(establecimiento) %></p>

        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <div class="mensaje-ok">La consulta se guardó correctamente en el historial del paciente.</div>
        <% } %>
        <% if (errorCarga) { %>
            <div class="mensaje-error">No se pudieron cargar tus citas. Verifica la conexión con la base de datos e inténtalo nuevamente.</div>
        <% } %>

        <section class="resumen">
            <div class="dato"><strong><%= citasHoy.size() %></strong><span>Citas hoy</span></div>
            <div class="dato"><strong><%= citasProximas.size() %></strong><span>Próximas citas</span></div>
        </section>

        <section class="bloque">
            <h2>Citas de hoy</h2>
            <% if (citasHoy.isEmpty()) { %>
                <p class="vacio">No tienes citas programadas para hoy.</p>
            <% } else { %>
                <%= tabla(citasHoy, false) %>
            <% } %>
        </section>

        <section class="bloque">
            <h2>Próximas citas</h2>
            <% if (citasProximas.isEmpty()) { %>
                <p class="vacio">No tienes citas programadas en los próximos días.</p>
            <% } else { %>
                <%= tabla(citasProximas, true) %>
            <% } %>
        </section>
    </main>
</body>
</html>
