<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="Conexion.ConexionDB"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String esc(String texto) {
        if (texto == null) return "";
        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String mostrar(String texto) {
        if (texto == null || texto.trim().isEmpty()) {
            return "Pendiente de completar";
        }
        return esc(texto);
    }
%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (!"PACIENTE".equals(session.getAttribute("rol"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String dniSesion = (String) session.getAttribute("usuarioDni");

    if (dniSesion == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombres = "";
    String apellidos = "";
    String telefono = "";
    String email = "";
    String tipoDoc = "";
    String fechaNacimiento = "";
    String direccion = "";
    String grupoSanguineo = "";
    String alergias = "";
    String antecedentes = "";
    String enfermedades = "";
    String contactoEmergencia = "";
    String telefonoEmergencia = "";

    boolean pacienteEncontrado = false;
    boolean errorCarga = false;

    List<Map<String, String>> historial = new ArrayList<>();

    try (Connection con = ConexionDB.conectar()) {

        if (con == null) {
            throw new SQLException("No se pudo conectar con la base de datos.");
        }

        String sqlPaciente =
            "SELECT nombre, apellido, telefono, email, tipo_documento, " +
            "fecha_nacimiento, direccion, grupo_sanguineo, alergias, " +
            "antecedentes_medicos, enfermedades_cronicas, " +
            "contacto_emergencia, telefono_emergencia " +
            "FROM paciente WHERE numero_documento = ?";

        try (PreparedStatement ps = con.prepareStatement(sqlPaciente)) {

            ps.setString(1, dniSesion);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    pacienteEncontrado = true;

                    nombres = rs.getString("nombre");
                    apellidos = rs.getString("apellido");
                    telefono = rs.getString("telefono");
                    email = rs.getString("email");
                    tipoDoc = rs.getString("tipo_documento");

                    java.sql.Date nacimiento = rs.getDate("fecha_nacimiento");

                    if (nacimiento != null) {
                        fechaNacimiento = nacimiento.toLocalDate()
                            .format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                    }

                    direccion = rs.getString("direccion");
                    grupoSanguineo = rs.getString("grupo_sanguineo");
                    alergias = rs.getString("alergias");
                    antecedentes = rs.getString("antecedentes_medicos");
                    enfermedades = rs.getString("enfermedades_cronicas");
                    contactoEmergencia = rs.getString("contacto_emergencia");
                    telefonoEmergencia = rs.getString("telefono_emergencia");
                }
            }
        }

        if (pacienteEncontrado) {
            String sqlHistorial =
                "SELECT h.fecha_consulta, h.motivo_consulta, " +
                "h.diagnostico, h.tratamiento, h.medicamentos, " +
                "h.observaciones, m.nombre AS medico_nombre, " +
                "m.especialidad " +
                "FROM historial_clinico h " +
                "LEFT JOIN medico m ON h.id_medico = m.id " +
                "WHERE h.numero_documento = ? " +
                "ORDER BY h.fecha_consulta DESC";

            try (PreparedStatement ps = con.prepareStatement(sqlHistorial)) {
                ps.setString(1, dniSesion);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> consulta = new HashMap<>();

                        Timestamp fecha = rs.getTimestamp("fecha_consulta");

                        consulta.put("fecha",
                            fecha != null
                                ? fecha.toLocalDateTime().format(
                                    DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                                : "");

                        consulta.put("motivo", rs.getString("motivo_consulta"));
                        consulta.put("diagnostico", rs.getString("diagnostico"));
                        consulta.put("tratamiento", rs.getString("tratamiento"));
                        consulta.put("medicamentos", rs.getString("medicamentos"));
                        consulta.put("observaciones", rs.getString("observaciones"));
                        consulta.put("medico", rs.getString("medico_nombre"));
                        consulta.put("especialidad", rs.getString("especialidad"));

                        historial.add(consulta);
                    }
                }
            }
        }

    } catch (Exception e) {
        errorCarga = true;
        application.log("Error al cargar el perfil y el historial de SaludClick", e);
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Mi Perfil</title>

    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Arial, sans-serif;
        }

        body {
            display: flex;
            min-height: 100vh;
            background: #f1f5f9;
            color: #1e293b;
        }

        .sidebar {
            width: 250px;
            flex-shrink: 0;
            background: #1e3a8a;
            color: white;
            padding: 25px 15px;
            display: flex;
            flex-direction: column;
        }

        .logo {
            width: 160px;
            max-width: 100%;
            margin: 0 auto 35px;
        }

        .sidebar a {
            display: block;
            text-decoration: none;
            color: #dbeafe;
            padding: 13px 14px;
            border-radius: 9px;
            margin-bottom: 9px;
            font-weight: 600;
        }

        .sidebar a:hover,
        .sidebar a.active {
            background: #2563eb;
            color: white;
        }

        .sidebar .logout {
            margin-top: auto;
            background: #b91c1c;
            color: white;
            text-align: center;
        }

        .main-content {
            flex: 1;
            min-width: 0;
            padding: 32px;
            overflow-x: hidden;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            border-bottom: 1px solid #dbe3ee;
            padding-bottom: 22px;
            margin-bottom: 25px;
        }

        .header h1 {
            color: #0f172a;
            font-size: 28px;
            margin-bottom: 7px;
        }

        .subtitulo {
            color: #64748b;
        }

        .resumen {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 25px;
        }

        .resumen-card {
            background: white;
            padding: 22px;
            border-radius: 13px;
            border-left: 5px solid #2563eb;
            box-shadow: 0 3px 10px rgba(15, 23, 42, .04);
        }

        .resumen-card .icono {
            font-size: 25px;
            margin-bottom: 10px;
        }

        .resumen-card strong {
            display: block;
            color: #1e3a8a;
            font-size: 25px;
            margin-bottom: 5px;
        }

        .resumen-card span {
            color: #64748b;
            font-size: 14px;
        }

        .seccion {
            background: white;
            padding: 25px;
            border-radius: 14px;
            margin-bottom: 23px;
            box-shadow: 0 3px 10px rgba(15, 23, 42, .04);
        }

        .seccion-titulo {
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }

        .seccion-titulo h2 {
            color: #1e3a8a;
            font-size: 20px;
        }

        .datos-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 19px;
        }

        .dato {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            padding: 15px;
            border-radius: 10px;
            min-width: 0;
        }

        .dato label {
            display: block;
            color: #64748b;
            font-size: 13px;
            margin-bottom: 7px;
            font-weight: 600;
        }

        .dato p {
            font-size: 15px;
            font-weight: 600;
            color: #1e293b;
            overflow-wrap: anywhere;
            white-space: pre-wrap;
        }

        .grupo-sanguineo {
            color: #b91c1c !important;
            font-size: 23px !important;
        }

        .historial-item {
            border: 1px solid #e2e8f0;
            border-left: 5px solid #2563eb;
            border-radius: 10px;
            padding: 19px;
            margin-bottom: 16px;
        }

        .historial-fecha {
            color: #2563eb;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .historial-item h3 {
            color: #1e3a8a;
            font-size: 16px;
            margin: 15px 0 6px;
        }

        .historial-item p {
            white-space: pre-wrap;
            overflow-wrap: anywhere;
            line-height: 1.6;
            color: #475569;
        }

        .vacio {
            padding: 25px;
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            color: #64748b;
            line-height: 1.7;
            text-align: center;
        }

        .aviso {
            padding: 15px 18px;
            border-radius: 10px;
            margin-bottom: 22px;
            background: #fef3c7;
            color: #92400e;
        }

        .error {
            padding: 15px 18px;
            border-radius: 10px;
            margin-bottom: 22px;
            background: #fee2e2;
            color: #991b1b;
        }

        .btn-volver {
            display: inline-block;
            background: #2563eb;
            color: white;
            padding: 13px 20px;
            border-radius: 9px;
            text-decoration: none;
            font-weight: 700;
        }

        .btn-volver:hover {
            background: #1d4ed8;
        }

        @media (max-width: 950px) {
            .sidebar { width: 210px; }
            .main-content { padding: 22px; }
            .resumen { grid-template-columns: 1fr; }
        }

        @media (max-width: 650px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; }
            .logo { width: 125px; margin-bottom: 20px; }
            .sidebar .logout { margin-top: 10px; }
            .main-content { padding: 16px; }
            .datos-grid { grid-template-columns: 1fr; }
            .header h1 { font-size: 23px; }
            .seccion { padding: 18px; }
        }
    </style>
</head>

<body>

    <aside class="sidebar">
        <img class="logo" src="img/logoblanco.png" alt="SaludClick">

        <a href="panel_paciente.jsp">📅 Mis Citas</a>
        <a href="perfil_paciente.jsp" class="active">👤 Mi Perfil</a>
        <a href="clinicas_postas.jsp">🏥 Clínicas y Postas</a>

        <a href="LogoutServlet" class="logout">Cerrar Sesión</a>
    </aside>

    <main class="main-content">

        <header class="header">
            <div>
                <h1>Mi perfil de salud</h1>
                <p class="subtitulo">
                    Consulta tus datos personales y la información médica registrada.
                </p>
            </div>
        </header>

        <% if (errorCarga) { %>
            <div class="error">
                No se pudo cargar toda la información. Verifica la conexión e inténtalo nuevamente.
            </div>
        <% } %>

        <% if (!errorCarga && !pacienteEncontrado) { %>
            <div class="aviso">
                No se encontró un paciente asociado a tu sesión.
                Cierra sesión e ingresa nuevamente.
            </div>
        <% } %>

        <% if (pacienteEncontrado) { %>

            <section class="resumen">

                <div class="resumen-card">
                    <div class="icono">📋</div>
                    <strong><%= historial.size() %></strong>
                    <span>Consultas registradas</span>
                </div>

                <div class="resumen-card">
                    <div class="icono">🩸</div>
                    <strong>
                        <%= grupoSanguineo != null && !grupoSanguineo.trim().isEmpty()
                            ? esc(grupoSanguineo) : "—" %>
                    </strong>
                    <span>Grupo sanguíneo informado</span>
                </div>

                <div class="resumen-card">
                    <div class="icono">👤</div>
                    <strong><%= esc(tipoDoc) %></strong>
                    <span><%= esc(dniSesion) %></span>
                </div>

            </section>

            <section class="seccion">
                <div class="seccion-titulo">
                    <span>👤</span>
                    <h2>Datos personales</h2>
                </div>

                <div class="datos-grid">

                    <div class="dato">
                        <label>Nombres</label>
                        <p><%= mostrar(nombres) %></p>
                    </div>

                    <div class="dato">
                        <label>Apellidos</label>
                        <p><%= mostrar(apellidos) %></p>
                    </div>

                    <div class="dato">
                        <label>Tipo de documento</label>
                        <p><%= mostrar(tipoDoc) %></p>
                    </div>

                    <div class="dato">
                        <label>Número de documento</label>
                        <p><%= esc(dniSesion) %></p>
                    </div>

                    <div class="dato">
                        <label>Fecha de nacimiento</label>
                        <p><%= mostrar(fechaNacimiento) %></p>
                    </div>

                    <div class="dato">
                        <label>Teléfono</label>
                        <p><%= mostrar(telefono) %></p>
                    </div>

                    <div class="dato">
                        <label>Correo electrónico</label>
                        <p><%= mostrar(email) %></p>
                    </div>

                    <div class="dato">
                        <label>Dirección</label>
                        <p><%= mostrar(direccion) %></p>
                    </div>

                </div>
            </section>

            <section class="seccion">
                <div class="seccion-titulo">
                    <span>🩺</span>
                    <h2>Información médica</h2>
                </div>

                <div class="datos-grid">

                    <div class="dato">
                        <label>Grupo sanguíneo</label>
                        <p class="grupo-sanguineo">
                            <%= mostrar(grupoSanguineo) %>
                        </p>
                    </div>

                    <div class="dato">
                        <label>Alergias conocidas</label>
                        <p><%= mostrar(alergias) %></p>
                    </div>

                    <div class="dato">
                        <label>Antecedentes médicos</label>
                        <p><%= mostrar(antecedentes) %></p>
                    </div>

                    <div class="dato">
                        <label>Enfermedades crónicas</label>
                        <p><%= mostrar(enfermedades) %></p>
                    </div>

                </div>
            </section>

            <section class="seccion">
                <div class="seccion-titulo">
                    <span>🚨</span>
                    <h2>Contacto de emergencia</h2>
                </div>

                <div class="datos-grid">

                    <div class="dato">
                        <label>Nombre del contacto</label>
                        <p><%= mostrar(contactoEmergencia) %></p>
                    </div>

                    <div class="dato">
                        <label>Teléfono del contacto</label>
                        <p><%= mostrar(telefonoEmergencia) %></p>
                    </div>

                </div>
            </section>

            <section class="seccion">
                <div class="seccion-titulo">
                    <span>📋</span>
                    <h2>Historial de consultas médicas</h2>
                </div>

                <% if (historial.isEmpty()) { %>

                    <div class="vacio">
                        <h3>🩺 Aún no tienes consultas registradas</h3>
                        <p>
                            Cuando un médico autorizado registre una consulta,
                            su fecha, diagnóstico y tratamiento aparecerán aquí.
                        </p>
                    </div>

                <% } else { %>

                    <% for (Map<String, String> consulta : historial) { %>

                        <article class="historial-item">

                            <div class="historial-fecha">
                                📅 <%= esc(consulta.get("fecha")) %>
                            </div>

                            <p>
                                <strong>Médico:</strong>
                                <%= mostrar(consulta.get("medico")) %>
                            </p>

                            <p>
                                <strong>Especialidad:</strong>
                                <%= mostrar(consulta.get("especialidad")) %>
                            </p>

                            <h3>Motivo de consulta</h3>
                            <p><%= mostrar(consulta.get("motivo")) %></p>

                            <h3>Diagnóstico</h3>
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

        <% } %>

        <a href="panel_paciente.jsp" class="btn-volver">
            ← Volver a Mis Citas
        </a>

    </main>

</body>
</html>