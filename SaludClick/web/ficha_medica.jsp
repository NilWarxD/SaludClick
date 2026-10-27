<%-- 
    Document   : ficha_medica
    Created on : 20 oct. 2026, 8:53:58 p. m.
    Author     : AMD
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.time.LocalDate, Conexion.ConexionDB"%>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String limpio(String s) {
        return s == null ? "" : s.trim();
    }

    private String nullable(String s) {
        String v = limpio(s);
        return v.isEmpty() ? null : v;
    }

    private String seleccionado(String actual, String opcion) {
        return opcion.equals(actual) ? "selected" : "";
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

    int citaId = -1;
    try { citaId = Integer.parseInt(request.getParameter("citaId")); }
    catch (Exception ignored) { }
    if (citaId <= 0) {
        response.sendRedirect("panel_medico.jsp");
        return;
    }

    String documento = "";
    String nombrePaciente = "";
    String tipoDocumento = "";
    String fechaCita = "";
    String horaCita = "";
    String fechaNacimiento = "";
    String direccion = "";
    String grupoSanguineo = "";
    String alergias = "";
    String antecedentes = "";
    String enfermedades = "";
    String contactoEmergencia = "";
    String telefonoEmergencia = "";
    String error = "";
    String exito = "";
    boolean autorizada = false;

    try (Connection con = ConexionDB.conectar()) {
        if (con == null) throw new SQLException("No se pudo conectar con la base de datos.");

        String sqlPaciente = "SELECT c.id, c.numero_documento, c.fecha_cita, c.hora_cita, "
                + "p.nombre, p.apellido, p.tipo_documento, p.fecha_nacimiento, p.direccion, "
                + "p.grupo_sanguineo, p.alergias, p.antecedentes_medicos, p.enfermedades_cronicas, "
                + "p.contacto_emergencia, p.telefono_emergencia "
                + "FROM cita c JOIN paciente p ON p.numero_documento = c.numero_documento "
                + "WHERE c.id = ? AND c.id_medico = ?";

        try (PreparedStatement ps = con.prepareStatement(sqlPaciente)) {
            ps.setInt(1, citaId);
            ps.setInt(2, medicoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    autorizada = true;
                    documento = rs.getString("numero_documento");
                    nombrePaciente = rs.getString("nombre") + " " + rs.getString("apellido");
                    tipoDocumento = rs.getString("tipo_documento");
                    fechaCita = rs.getString("fecha_cita");
                    horaCita = rs.getString("hora_cita");
                    java.sql.Date nacimiento = rs.getDate("fecha_nacimiento");
                    fechaNacimiento = nacimiento == null ? "" : nacimiento.toString();
                    direccion = limpio(rs.getString("direccion"));
                    grupoSanguineo = limpio(rs.getString("grupo_sanguineo"));
                    alergias = limpio(rs.getString("alergias"));
                    antecedentes = limpio(rs.getString("antecedentes_medicos"));
                    enfermedades = limpio(rs.getString("enfermedades_cronicas"));
                    contactoEmergencia = limpio(rs.getString("contacto_emergencia"));
                    telefonoEmergencia = limpio(rs.getString("telefono_emergencia"));
                }
            }
        }

        if (!autorizada) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "No tienes permiso para acceder a la ficha de este paciente.");
            return;
        }

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            fechaNacimiento = limpio(request.getParameter("fechaNacimiento"));
            direccion = limpio(request.getParameter("direccion"));
            grupoSanguineo = limpio(request.getParameter("grupoSanguineo"));
            alergias = limpio(request.getParameter("alergias"));
            antecedentes = limpio(request.getParameter("antecedentes"));
            enfermedades = limpio(request.getParameter("enfermedades"));
            contactoEmergencia = limpio(request.getParameter("contactoEmergencia"));
            telefonoEmergencia = limpio(request.getParameter("telefonoEmergencia"));

            String[] gruposPermitidos = {"", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "No sabe"};
            boolean grupoValido = false;
            for (String grupo : gruposPermitidos) {
                if (grupo.equals(grupoSanguineo)) { grupoValido = true; break; }
            }
            if (!grupoValido) {
                error = "Selecciona un grupo sanguíneo válido o deja el campo sin indicar.";
            }

            java.sql.Date fechaSql = null;
            if (error.isEmpty() && !fechaNacimiento.isEmpty()) {
                try {
                    fechaSql = java.sql.Date.valueOf(fechaNacimiento);
                    if (fechaSql.toLocalDate().isAfter(LocalDate.now())) {
                        error = "La fecha de nacimiento no puede estar en el futuro.";
                    }
                } catch (IllegalArgumentException ex) {
                    error = "La fecha de nacimiento no tiene un formato válido.";
                }
            }

            if (error.isEmpty()) {
                String sqlUpdate = "UPDATE paciente SET fecha_nacimiento = ?, direccion = ?, "
                        + "grupo_sanguineo = ?, alergias = ?, antecedentes_medicos = ?, "
                        + "enfermedades_cronicas = ?, contacto_emergencia = ?, telefono_emergencia = ? "
                        + "WHERE numero_documento = ?";
                try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
                    if (fechaSql == null) ps.setNull(1, java.sql.Types.DATE); else ps.setDate(1, fechaSql);
                    ps.setString(2, nullable(direccion));
                    ps.setString(3, nullable(grupoSanguineo));
                    ps.setString(4, nullable(alergias));
                    ps.setString(5, nullable(antecedentes));
                    ps.setString(6, nullable(enfermedades));
                    ps.setString(7, nullable(contactoEmergencia));
                    ps.setString(8, nullable(telefonoEmergencia));
                    ps.setString(9, documento);
                    ps.executeUpdate();
                }
                exito = "Ficha médica guardada correctamente. Los cambios ya están disponibles en el perfil del paciente.";
            }
        }
    } catch (SQLException e) {
        application.log("Error al cargar o actualizar la ficha médica", e);
        if (error.isEmpty()) error = "No se pudo guardar la ficha médica. Comprueba la conexión e inténtalo de nuevo.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Ficha médica</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', system-ui, sans-serif; }
        body { margin: 0; background: #f1f5f9; color: #1e293b; }
        header { background: #1e3a8a; color: #fff; padding: 22px 30px; }
        header h1 { margin: 0 0 6px; font-size: 25px; }
        header p { margin: 0; color: #dbeafe; }
        main { max-width: 1050px; margin: 28px auto; padding: 0 20px 35px; }
        .card { background: #fff; padding: 25px; border-radius: 14px; margin-bottom: 22px; box-shadow: 0 3px 10px rgba(15,23,42,.05); }
        h2 { color: #1e3a8a; font-size: 20px; margin: 0 0 18px; padding-bottom: 12px; border-bottom: 1px solid #e2e8f0; }
        .datos, .form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
        .dato { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 9px; padding: 14px; overflow-wrap: anywhere; }
        .dato span { display: block; color: #64748b; font-size: 13px; margin-bottom: 6px; }
        label { display: block; font-weight: 700; color: #334155; margin: 12px 0 7px; }
        input, select, textarea { width: 100%; border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px; font-size: 15px; color: #1e293b; background: #fff; }
        textarea { min-height: 100px; resize: vertical; }
        input:focus, select:focus, textarea:focus { outline: 2px solid #bfdbfe; border-color: #2563eb; }
        .ayuda { color: #64748b; font-size: 13px; line-height: 1.5; margin: 10px 0 0; }
        .error, .exito { padding: 14px 17px; border-radius: 9px; margin-bottom: 18px; line-height: 1.55; }
        .error { background: #fee2e2; border: 1px solid #fecaca; color: #991b1b; }
        .exito { background: #dcfce7; border: 1px solid #bbf7d0; color: #166534; }
        .botones { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 22px; }
        .btn { display: inline-block; border: 0; border-radius: 8px; padding: 12px 18px; font-weight: 700; cursor: pointer; text-decoration: none; font-size: 15px; }
        .primario { background: #10b981; color: #fff; }
        .primario:hover { background: #059669; }
        .secundario { background: #e2e8f0; color: #1e293b; }
        .secundario:hover { background: #cbd5e1; }
        @media (max-width: 700px) { header { padding: 20px; } .datos, .form-grid { grid-template-columns: 1fr; } .card { padding: 18px; } }
    </style>
</head>
<body>
<header>
    <h1>Ficha médica del paciente</h1>
    <p>SaludClick · Información proporcionada o verificada durante la atención</p>
</header>
<main>
    <% if (!error.isEmpty()) { %><div class="error"><%= esc(error) %></div><% } %>
    <% if (!exito.isEmpty()) { %><div class="exito"><strong><%= esc(exito) %></strong></div><% } %>

    <section class="card">
        <h2>Datos de la cita</h2>
        <div class="datos">
            <div class="dato"><span>Paciente</span><strong><%= esc(nombrePaciente) %></strong></div>
            <div class="dato"><span>Documento</span><strong><%= esc(tipoDocumento) %> · <%= esc(documento) %></strong></div>
            <div class="dato"><span>Fecha de la cita</span><strong><%= esc(fechaCita) %></strong></div>
            <div class="dato"><span>Hora</span><strong><%= esc(horaCita != null && horaCita.length() >= 5 ? horaCita.substring(0,5) : horaCita) %></strong></div>
        </div>
    </section>

    <form method="post" action="ficha_medica.jsp?citaId=<%= citaId %>">
        <section class="card">
            <h2>Datos complementarios</h2>
            <div class="form-grid">
                <div>
                    <label for="fechaNacimiento">Fecha de nacimiento</label>
                    <input type="date" id="fechaNacimiento" name="fechaNacimiento" value="<%= esc(fechaNacimiento) %>" max="<%= LocalDate.now().toString() %>">
                </div>
                <div>
                    <label for="direccion">Dirección</label>
                    <input type="text" id="direccion" name="direccion" maxlength="180" value="<%= esc(direccion) %>" placeholder="Dirección confirmada por el paciente">
                </div>
                <div>
                    <label for="grupoSanguineo">Grupo sanguíneo</label>
                    <select id="grupoSanguineo" name="grupoSanguineo">
                        <option value="" <%= seleccionado(grupoSanguineo, "") %>>No indicado</option>
                        <option value="A+" <%= seleccionado(grupoSanguineo, "A+") %>>A+</option>
                        <option value="A-" <%= seleccionado(grupoSanguineo, "A-") %>>A−</option>
                        <option value="B+" <%= seleccionado(grupoSanguineo, "B+") %>>B+</option>
                        <option value="B-" <%= seleccionado(grupoSanguineo, "B-") %>>B−</option>
                        <option value="AB+" <%= seleccionado(grupoSanguineo, "AB+") %>>AB+</option>
                        <option value="AB-" <%= seleccionado(grupoSanguineo, "AB-") %>>AB−</option>
                        <option value="O+" <%= seleccionado(grupoSanguineo, "O+") %>>O+</option>
                        <option value="O-" <%= seleccionado(grupoSanguineo, "O-") %>>O−</option>
                        <option value="No sabe" <%= seleccionado(grupoSanguineo, "No sabe") %>>No lo conoce</option>
                    </select>
                </div>
                <div>
                    <label for="alergias">Alergias conocidas</label>
                    <textarea id="alergias" name="alergias" maxlength="6000" placeholder="Indicar alergias confirmadas o no referidas"><%= esc(alergias) %></textarea>
                </div>
                <div>
                    <label for="antecedentes">Antecedentes médicos</label>
                    <textarea id="antecedentes" name="antecedentes" maxlength="6000" placeholder="Antecedentes relevantes proporcionados o verificados"><%= esc(antecedentes) %></textarea>
                </div>
                <div>
                    <label for="enfermedades">Enfermedades crónicas</label>
                    <textarea id="enfermedades" name="enfermedades" maxlength="6000" placeholder="Enfermedades crónicas conocidas, si las hubiera"><%= esc(enfermedades) %></textarea>
                </div>
                <div>
                    <label for="contactoEmergencia">Nombre del contacto de emergencia</label>
                    <input type="text" id="contactoEmergencia" name="contactoEmergencia" maxlength="100" value="<%= esc(contactoEmergencia) %>" placeholder="Nombre completo">
                </div>
                <div>
                    <label for="telefonoEmergencia">Teléfono del contacto de emergencia</label>
                    <input type="tel" id="telefonoEmergencia" name="telefonoEmergencia" maxlength="20" value="<%= esc(telefonoEmergencia) %>" placeholder="Teléfono de contacto">
                </div>
            </div>
            <p class="ayuda">Registra únicamente datos proporcionados por el paciente o confirmados en la atención. No deduzcas el grupo sanguíneo ni inventes antecedentes.</p>
            <div class="botones">
                <button class="btn primario" type="submit">Guardar ficha médica</button>
                <a class="btn secundario" href="panel_medico.jsp">Volver al panel</a>
            </div>
        </section>
    </form>
</main>
</body>
</html>
