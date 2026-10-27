<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.util.*, java.time.format.DateTimeFormatter, Conexion.ConexionDB"%>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String mostrar(String s) {
        return (s == null || s.trim().isEmpty()) ? "No registrado" : esc(s);
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Integer medicoId = (Integer) session.getAttribute("medicoId");
    if (!"MEDICO".equals(session.getAttribute("rol")) || medicoId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String citaParam = request.getParameter("citaId");
    int citaId = -1;
    try { citaId = Integer.parseInt(citaParam); } catch (Exception ignored) { }
    if (citaId <= 0) {
        response.sendRedirect("panel_medico.jsp");
        return;
    }

    String numeroDocumento = "";
    String fechaCita = "";
    String horaCita = "";
    String estadoCita = "";
    String nombrePaciente = "";
    String tipoDocumento = "";
    String telefonoPaciente = "";
    String correoPaciente = "";
    String nombreMedico = "";
    String especialidad = "";
    boolean citaAutorizada = false;
    boolean guardado = false;
    String error = "";
    List<Map<String, String>> historialAnterior = new ArrayList<>();
    DateTimeFormatter formatoHistorial = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    String motivo = request.getParameter("motivo");
    String diagnostico = request.getParameter("diagnostico");
    String tratamiento = request.getParameter("tratamiento");
    String medicamentos = request.getParameter("medicamentos");
    String observaciones = request.getParameter("observaciones");
    if (motivo == null) motivo = "";
    if (diagnostico == null) diagnostico = "";
    if (tratamiento == null) tratamiento = "";
    if (medicamentos == null) medicamentos = "";
    if (observaciones == null) observaciones = "";

    try (Connection con = ConexionDB.conectar()) {
        if (con == null) throw new SQLException("No se pudo conectar con la base de datos.");

        // Confirma que la cita corresponde al médico que inició sesión.
        String sqlCita = "SELECT c.id, c.numero_documento, c.fecha_cita, c.hora_cita, c.estado, "
                + "p.nombre, p.apellido, p.tipo_documento, p.telefono, p.email, "
                + "m.nombre AS medico_nombre, m.especialidad "
                + "FROM cita c JOIN paciente p ON p.numero_documento = c.numero_documento "
                + "JOIN medico m ON m.id = c.id_medico "
                + "WHERE c.id = ? AND c.id_medico = ?";

        try (PreparedStatement ps = con.prepareStatement(sqlCita)) {
            ps.setInt(1, citaId);
            ps.setInt(2, medicoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    citaAutorizada = true;
                    numeroDocumento = rs.getString("numero_documento");
                    fechaCita = rs.getString("fecha_cita");
                    horaCita = rs.getString("hora_cita");
                    estadoCita = rs.getString("estado");
                    nombrePaciente = rs.getString("nombre") + " " + rs.getString("apellido");
                    tipoDocumento = rs.getString("tipo_documento");
                    telefonoPaciente = rs.getString("telefono");
                    correoPaciente = rs.getString("email");
                    nombreMedico = rs.getString("medico_nombre");
                    especialidad = rs.getString("especialidad");
                }
            }
        }

        if (!citaAutorizada) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No tienes permiso para registrar una consulta para esta cita.");
            return;
        }

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            motivo = motivo.trim();
            diagnostico = diagnostico.trim();
            tratamiento = tratamiento.trim();
            medicamentos = medicamentos.trim();
            observaciones = observaciones.trim();

            if ("Atendida".equalsIgnoreCase(estadoCita) || "Cancelada".equalsIgnoreCase(estadoCita)) {
                error = "Esta cita ya figura como " + estadoCita.toLowerCase() + ". No se puede registrar otra consulta con la misma cita.";
            } else if (motivo.isEmpty() || diagnostico.isEmpty()) {
                error = "Completa al menos el motivo de consulta y el diagnóstico.";
            } else {
                con.setAutoCommit(false);
                try {
                    String sqlInsert = "INSERT INTO historial_clinico "
                            + "(numero_documento, id_medico, motivo_consulta, diagnostico, tratamiento, medicamentos, observaciones) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = con.prepareStatement(sqlInsert)) {
                        ps.setString(1, numeroDocumento);
                        ps.setInt(2, medicoId);
                        ps.setString(3, motivo);
                        ps.setString(4, diagnostico);
                        ps.setString(5, tratamiento.isEmpty() ? null : tratamiento);
                        ps.setString(6, medicamentos.isEmpty() ? null : medicamentos);
                        ps.setString(7, observaciones.isEmpty() ? null : observaciones);
                        ps.executeUpdate();
                    }

                    // Marca la cita como atendida en la misma transacción.
                    String sqlActualizarCita = "UPDATE cita SET estado = 'Atendida' "
                            + "WHERE id = ? AND id_medico = ? "
                            + "AND LOWER(estado) NOT IN ('atendida', 'cancelada')";
                    try (PreparedStatement ps = con.prepareStatement(sqlActualizarCita)) {
                        ps.setInt(1, citaId);
                        ps.setInt(2, medicoId);
                        int filasActualizadas = ps.executeUpdate();
                        if (filasActualizadas != 1) {
                            throw new SQLException("No se pudo actualizar el estado de la cita. Comprueba si ya fue atendida o cancelada.");
                        }
                    }

                    con.commit();
                    estadoCita = "Atendida";
                    guardado = true;
                } catch (SQLException ex) {
                    con.rollback();
                    throw ex;
                } finally {
                    con.setAutoCommit(true);
                }
            }
        }

        // Muestra las consultas anteriores del mismo paciente. Después de guardar,
        // incluye también la consulta recién registrada.
        String sqlHistorial = "SELECT h.fecha_consulta, h.motivo_consulta, h.diagnostico, "
                + "h.tratamiento, h.medicamentos, h.observaciones, "
                + "m.nombre AS medico_nombre, m.especialidad "
                + "FROM historial_clinico h LEFT JOIN medico m ON m.id = h.id_medico "
                + "WHERE h.numero_documento = ? "
                + "ORDER BY h.fecha_consulta DESC, h.id DESC";
        try (PreparedStatement ps = con.prepareStatement(sqlHistorial)) {
            ps.setString(1, numeroDocumento);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> consulta = new HashMap<>();
                    Timestamp fecha = rs.getTimestamp("fecha_consulta");
                    consulta.put("fecha", fecha != null
                            ? fecha.toLocalDateTime().format(formatoHistorial) : "Fecha no disponible");
                    consulta.put("motivo", rs.getString("motivo_consulta"));
                    consulta.put("diagnostico", rs.getString("diagnostico"));
                    consulta.put("tratamiento", rs.getString("tratamiento"));
                    consulta.put("medicamentos", rs.getString("medicamentos"));
                    consulta.put("observaciones", rs.getString("observaciones"));
                    consulta.put("medico", rs.getString("medico_nombre"));
                    consulta.put("especialidad", rs.getString("especialidad"));
                    historialAnterior.add(consulta);
                }
            }
        }
    } catch (SQLException e) {
        application.log("Error al abrir, consultar historial o guardar la consulta médica", e);
        if (error.isEmpty()) error = "No se pudo cargar o guardar la información. Comprueba la base de datos e inténtalo nuevamente.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Registrar consulta</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', system-ui, sans-serif; }
        body { margin: 0; background: #f1f5f9; color: #1e293b; }
        header { background: #1e3a8a; color: white; padding: 22px 30px; }
        header h1 { margin: 0 0 5px; font-size: 25px; }
        header p { margin: 0; color: #dbeafe; }
        main { max-width: 1100px; margin: 28px auto; padding: 0 20px 30px; }
        .card { background: white; border-radius: 14px; padding: 25px; margin-bottom: 22px; box-shadow: 0 3px 10px rgba(15,23,42,.05); }
        h2 { margin: 0 0 18px; color: #1e3a8a; font-size: 20px; }
        .datos { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
        .dato { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 9px; padding: 13px; overflow-wrap: anywhere; }
        .dato span { display: block; font-size: 13px; color: #64748b; margin-bottom: 6px; }
        .dato strong { color: #1e293b; }
        label { display: block; font-weight: 700; color: #334155; margin: 17px 0 7px; }
        input, textarea { width: 100%; border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px; font-size: 15px; background: white; }
        textarea { min-height: 95px; resize: vertical; }
        input:focus, textarea:focus { outline: 2px solid #bfdbfe; border-color: #2563eb; }
        .nota { color: #64748b; font-size: 13px; margin-top: 12px; line-height: 1.5; }
        .error { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; padding: 13px 16px; border-radius: 9px; margin-bottom: 18px; }
        .exito { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; padding: 18px; border-radius: 10px; line-height: 1.7; }
        .botones { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 22px; }
        .btn { display: inline-block; border: 0; border-radius: 8px; padding: 12px 18px; font-weight: 700; cursor: pointer; text-decoration: none; font-size: 15px; }
        .primario { background: #10b981; color: white; }
        .primario:hover { background: #059669; }
        .secundario { background: #e2e8f0; color: #1e293b; }
        .secundario:hover { background: #cbd5e1; }
        .historial-item { border: 1px solid #e2e8f0; border-left: 5px solid #2563eb; border-radius: 10px; padding: 18px; margin-bottom: 15px; }
        .historial-fecha { color: #2563eb; font-weight: 700; margin-bottom: 12px; }
        .historial-item h3 { margin: 14px 0 5px; color: #1e3a8a; font-size: 15px; }
        .historial-item p { margin: 0; color: #475569; line-height: 1.6; white-space: pre-wrap; overflow-wrap: anywhere; }
        .vacio { background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 9px; padding: 18px; color: #64748b; line-height: 1.6; }
        @media (max-width: 650px) { header { padding: 20px; } .datos { grid-template-columns: 1fr; } .card { padding: 18px; } }
    </style>
</head>
<body>
<header>
    <h1>Registrar consulta médica</h1>
    <p>SaludClick · Registro clínico del paciente</p>
</header>
<main>
    <% if (!error.isEmpty()) { %>
        <div class="error"><%= esc(error) %></div>
    <% } %>

    <% if (guardado) { %>
        <section class="card">
            <div class="exito">
                <strong>Consulta guardada correctamente.</strong><br>
                El registro se añadió al historial del paciente y la cita quedó marcada como Atendida. Puedes revisar la consulta y sus antecedentes en la sección siguiente.
            </div>
            <div class="botones">
                <a class="btn primario" href="panel_medico.jsp?guardado=1">Volver al panel médico</a>
            </div>
        </section>
    <% } %>

    <% if (citaAutorizada) { %>
        <section class="card">
            <h2>Datos de la cita</h2>
            <div class="datos">
                <div class="dato"><span>Paciente</span><strong><%= esc(nombrePaciente) %></strong></div>
                <div class="dato"><span>Documento</span><strong><%= esc(tipoDocumento) %> · <%= esc(numeroDocumento) %></strong></div>
                <div class="dato"><span>Fecha de la cita</span><strong><%= esc(fechaCita) %></strong></div>
                <div class="dato"><span>Hora</span><strong><%= esc(horaCita != null && horaCita.length() >= 5 ? horaCita.substring(0,5) : horaCita) %></strong></div>
                <div class="dato"><span>Estado de la cita</span><strong><%= esc(estadoCita) %></strong></div>
                <div class="dato"><span>Médico</span><strong><%= esc(nombreMedico) %></strong></div>
                <div class="dato"><span>Especialidad</span><strong><%= esc(especialidad) %></strong></div>
                <div class="dato"><span>Teléfono del paciente</span><strong><%= mostrar(telefonoPaciente) %></strong></div>
                <div class="dato"><span>Correo del paciente</span><strong><%= mostrar(correoPaciente) %></strong></div>
            </div>
        </section>

        <section class="card">
            <h2>Historial previo del paciente</h2>
            <p class="nota" style="margin-top:-8px;margin-bottom:16px">Revisa los registros anteriores antes de añadir una nueva consulta. Solo se muestran datos guardados en SaludClick.</p>
            <% if (historialAnterior.isEmpty()) { %>
                <div class="vacio">Este paciente todavía no tiene consultas registradas.</div>
            <% } else { %>
                <% for (Map<String, String> consulta : historialAnterior) { %>
                    <article class="historial-item">
                        <div class="historial-fecha">📅 <%= esc(consulta.get("fecha")) %></div>
                        <p><strong>Médico:</strong> <%= mostrar(consulta.get("medico")) %></p>
                        <p><strong>Especialidad:</strong> <%= mostrar(consulta.get("especialidad")) %></p>
                        <h3>Motivo de consulta</h3>
                        <p><%= mostrar(consulta.get("motivo")) %></p>
                        <h3>Diagnóstico registrado</h3>
                        <p><%= mostrar(consulta.get("diagnostico")) %></p>
                        <h3>Tratamiento</h3>
                        <p><%= mostrar(consulta.get("tratamiento")) %></p>
                        <h3>Medicamentos</h3>
                        <p><%= mostrar(consulta.get("medicamentos")) %></p>
                        <h3>Observaciones e indicaciones</h3>
                        <p><%= mostrar(consulta.get("observaciones")) %></p>
                    </article>
                <% } %>
            <% } %>
        </section>

        <% if (!guardado && ("Atendida".equalsIgnoreCase(estadoCita) || "Cancelada".equalsIgnoreCase(estadoCita))) { %>
            <section class="card">
                <div class="nota"><strong>Esta cita ya no está pendiente.</strong> Su estado actual es <%= esc(estadoCita) %>. El historial puede consultarse, pero no se habilita un nuevo registro desde esta misma cita.</div>
            </section>
        <% } %>

        <% if (!guardado && !"Atendida".equalsIgnoreCase(estadoCita) && !"Cancelada".equalsIgnoreCase(estadoCita)) { %>
            <section class="card">
                <h2>Registrar una nueva consulta</h2>
                <form method="post" action="registrar_consulta.jsp?citaId=<%= citaId %>">
                    <label for="motivo">Motivo de consulta *</label>
                    <textarea id="motivo" name="motivo" maxlength="255" required><%= esc(motivo) %></textarea>

                    <label for="diagnostico">Diagnóstico *</label>
                    <textarea id="diagnostico" name="diagnostico" required><%= esc(diagnostico) %></textarea>

                    <label for="tratamiento">Tratamiento indicado</label>
                    <textarea id="tratamiento" name="tratamiento"><%= esc(tratamiento) %></textarea>

                    <label for="medicamentos">Medicamentos recetados</label>
                    <textarea id="medicamentos" name="medicamentos"><%= esc(medicamentos) %></textarea>

                    <label for="observaciones">Observaciones e indicaciones para el paciente</label>
                    <textarea id="observaciones" name="observaciones"><%= esc(observaciones) %></textarea>

                    <p class="nota">Los campos con * son obligatorios. Registra únicamente información clínica confirmada durante la atención.</p>
                    <div class="botones">
                        <button class="btn primario" type="submit">Guardar consulta</button>
                        <a class="btn secundario" href="panel_medico.jsp">Cancelar y volver</a>
                    </div>
                </form>
            </section>
        <% } %>
    <% } %>
</main>
</body>
</html>
