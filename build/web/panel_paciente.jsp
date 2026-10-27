<%@page import="java.sql.Connection"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.util.*"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="Conexion.ConexionDB"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    // Escapa texto para evitar que datos de la base de datos rompan el HTML.
    private String escaparHTML(String texto) {
        if (texto == null) return "";
        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    String dniSesion = (String) session.getAttribute("usuarioDni");

    if (dniSesion == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombrePaciente = "Paciente";
    Connection conNom = null;
    PreparedStatement psNom = null;
    ResultSet rsNom = null;

    try {
        conNom = ConexionDB.conectar();
        if (conNom != null) {
            String sqlNom = "SELECT nombre FROM paciente WHERE numero_documento = ?";
            psNom = conNom.prepareStatement(sqlNom);
            psNom.setString(1, dniSesion);
            rsNom = psNom.executeQuery();

            if (rsNom.next()) {
                nombrePaciente = rsNom.getString("nombre");
            }
        }
    } catch (Exception e) {
        application.log("Error al obtener el nombre del paciente", e);
    } finally {
        try { if (rsNom != null) rsNom.close(); } catch (Exception e) {}
        try { if (psNom != null) psNom.close(); } catch (Exception e) {}
        try { if (conNom != null) conNom.close(); } catch (Exception e) {}
    }

    // Total de citas asociadas al paciente que inició sesión.
    int citasRegistradas = 0;
    try (Connection conResumen = ConexionDB.conectar()) {
        if (conResumen != null) {
            try (PreparedStatement psResumen = conResumen.prepareStatement(
                    "SELECT COUNT(*) FROM cita WHERE numero_documento = ?")) {
                psResumen.setString(1, dniSesion);
                try (ResultSet rsResumen = psResumen.executeQuery()) {
                    if (rsResumen.next()) {
                        citasRegistradas = rsResumen.getInt(1);
                    }
                }
            }
        }
    } catch (Exception e) {
        application.log("Error al contar las citas del paciente", e);
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick | Panel del paciente</title>
    <style>
        :root {
            --azul: #1e3a8a;
            --azul-profundo: #173276;
            --azul-vivo: #2563eb;
            --turquesa: #10b981;
            --turquesa-hover: #059669;
            --fondo: #f3f7fc;
            --texto: #17243b;
            --texto-suave: #64748b;
            --borde: #e3eaf4;
            --blanco: #ffffff;
            --sombra: 0 12px 32px rgba(30, 58, 138, .07);
        }

        * { box-sizing: border-box; }
        html { min-height: 100%; }
        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            color: var(--texto);
            background: var(--fondo);
        }
        a { text-decoration: none; }

        .app { min-height: 100vh; display: flex; }

        .sidebar {
            width: 258px;
            flex: 0 0 258px;
            background: linear-gradient(180deg, var(--azul) 0%, var(--azul-profundo) 100%);
            color: white;
            padding: 25px 16px 18px;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        .brand {
            text-align: center;
            padding: 3px 0 27px;
        }
        .brand img {
            display: block;
            width: 174px;
            max-width: 100%;
            max-height: 76px;
            object-fit: contain;
            margin: 0 auto 8px;
        }
        .brand-caption { color: #dbeafe; font-size: 12px; letter-spacing: 1.4px; text-transform: uppercase; }
        .nav-label {
            color: #a9c8ff;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.5px;
            padding: 9px 12px;
            text-transform: uppercase;
        }
        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 13px 14px;
            margin: 3px 0;
            color: #dbeafe;
            border-radius: 11px;
            font-size: 14px;
            font-weight: 650;
            transition: background .2s, transform .2s;
        }
        .nav-link:hover { background: rgba(255,255,255,.1); transform: translateX(2px); }
        .nav-link.active {
            color: #fff;
            background: linear-gradient(90deg, #2563eb, #3274f5);
            box-shadow: 0 6px 16px rgba(0,0,0,.12);
        }
        .nav-icon { width: 22px; text-align: center; font-size: 17px; }
        .clinic-section { margin-top: 23px; }
        .clinic-card {
            background: white;
            border: 1px solid rgba(255,255,255,.35);
            border-radius: 11px;
            overflow: hidden;
            margin: 7px 0 10px;
            padding: 6px;
        }
        .clinic-card img { display: block; width: 100%; height: 56px; object-fit: contain; }
        .sidebar-spacer { flex: 1; min-height: 22px; }
        .logout {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 9px;
            color: #fff;
            background: #c62828;
            padding: 13px;
            border-radius: 10px;
            font-weight: 750;
            transition: background .2s;
        }
        .logout:hover { background: #a91e1e; }

        .main-content { min-width: 0; flex: 1; padding: 30px clamp(20px, 3vw, 44px); }
        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            padding-bottom: 22px;
            border-bottom: 1px solid #dce5f0;
            margin-bottom: 24px;
        }
        .eyebrow {
            color: var(--azul-vivo);
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 1.7px;
            margin-bottom: 7px;
        }
        .topbar h1 { font-size: clamp(25px, 2.4vw, 34px); margin: 0; letter-spacing: -.7px; }
        .topbar h1 span { color: var(--azul-vivo); }
        .topbar-note {
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--texto-suave);
            font-size: 13px;
            font-weight: 650;
            background: white;
            border: 1px solid var(--borde);
            border-radius: 30px;
            padding: 11px 15px;
            white-space: nowrap;
        }
        .online-dot { width: 8px; height: 8px; background: var(--turquesa); border-radius: 50%; box-shadow: 0 0 0 4px #d1fae5; }

        .welcome-banner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            padding: 22px 25px;
            margin-bottom: 22px;
            color: white;
            border-radius: 17px;
            background: linear-gradient(110deg, #1e40af, #2563eb 65%, #0d9488);
            box-shadow: 0 12px 25px rgba(37, 99, 235, .15);
        }
        .welcome-banner h2 { margin: 0 0 7px; font-size: 20px; }
        .welcome-banner p { margin: 0; color: #eaf2ff; font-size: 13px; line-height: 1.6; }
        .welcome-symbol {
            width: 58px; height: 58px; flex: 0 0 58px;
            display: grid; place-items: center;
            border-radius: 16px; background: rgba(255,255,255,.17);
            font-size: 29px;
        }

        .summary-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 15px; margin-bottom: 24px; }
        .summary-card {
            background: var(--blanco);
            border: 1px solid var(--borde);
            border-radius: 14px;
            padding: 18px 20px;
            box-shadow: 0 4px 12px rgba(15, 23, 42, .025);
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .summary-icon {
            width: 46px; height: 46px; flex: 0 0 46px;
            display: grid; place-items: center;
            border-radius: 13px; font-size: 21px;
        }
        .icon-blue { color: #1d4ed8; background: #dbeafe; }
        .icon-green { color: #047857; background: #d1fae5; }
        .icon-teal { color: #0f766e; background: #ccfbf1; }
        .summary-number { font-size: 23px; font-weight: 800; line-height: 1.2; }
        .summary-label { color: var(--texto-suave); font-size: 12px; margin-top: 4px; }

        .dashboard-grid { display: grid; grid-template-columns: minmax(0, 1.2fr) minmax(320px, .9fr); gap: 22px; align-items: start; }
        .card {
            background: white;
            border: 1px solid var(--borde);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--sombra);
            min-width: 0;
        }
        .card-heading {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            padding-bottom: 17px;
            margin-bottom: 20px;
            border-bottom: 1px solid #edf2f8;
        }
        .card-heading h3 { color: var(--azul); font-size: 18px; margin: 0 0 5px; }
        .card-heading p { color: var(--texto-suave); font-size: 12px; margin: 0; line-height: 1.5; }
        .section-icon {
            width: 39px; height: 39px; display: grid; place-items: center;
            flex: 0 0 39px; border-radius: 12px; background: #e0f2fe; font-size: 19px;
        }

        .field { margin-bottom: 17px; }
        .field label { display: block; color: #334155; font-size: 13px; font-weight: 750; margin-bottom: 8px; }
        .field-number { display: inline-grid; place-items: center; width: 22px; height: 22px; margin-right: 5px; border-radius: 7px; color: #1d4ed8; background: #dbeafe; font-size: 11px; }
        select, input {
            display: block; width: 100%; min-height: 47px; padding: 12px 13px;
            border: 1px solid #d6e0ed; border-radius: 10px;
            font: inherit; font-size: 13px; color: #24334a; background: #fff;
            outline: none; transition: border .2s, box-shadow .2s;
        }
        select:focus, input:focus { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,.12); }
        select:disabled { background: #f3f6fa; color: #9aa7b8; cursor: not-allowed; }
        .field-hint { margin-top: 6px; color: #8190a5; font-size: 11px; }
        .submit-button {
            display: flex; justify-content: center; align-items: center; gap: 9px;
            width: 100%; border: 0; border-radius: 10px; padding: 15px;
            color: white; background: linear-gradient(90deg, #10b981, #0d9f83);
            font: inherit; font-size: 14px; font-weight: 800; cursor: pointer;
            box-shadow: 0 7px 14px rgba(16,185,129,.17); transition: transform .2s, box-shadow .2s;
        }
        .submit-button:hover { transform: translateY(-1px); box-shadow: 0 10px 18px rgba(16,185,129,.23); }

        .appointments-list { display: flex; flex-direction: column; gap: 12px; }
        .appointment-item {
            display: flex; align-items: flex-start; justify-content: space-between; gap: 12px;
            padding: 16px; border: 1px solid #e7edf5; border-left: 4px solid var(--azul-vivo);
            border-radius: 11px; background: #fbfdff;
        }
        .appointment-info { min-width: 0; }
        .appointment-info h4 { color: #1e3a8a; font-size: 15px; margin: 0 0 9px; }
        .appointment-info p { color: #65758b; font-size: 12px; line-height: 1.6; margin: 4px 0; overflow-wrap: anywhere; }
        .appointment-info .doctor-name { color: #334155; font-weight: 650; }
        .status-badge {
            display: inline-block; white-space: nowrap;
            color: #1d4ed8; background: #dbeafe; border-radius: 20px;
            padding: 6px 9px; font-size: 10px; font-weight: 800;
        }
        .status-done { color: #047857; background: #d1fae5; }
        .status-cancelled { color: #b91c1c; background: #fee2e2; }
        .status-past { color: #92400e; background: #fef3c7; }
        .appointments-subtitle { margin: 18px 0 11px; color: #1e3a8a; font-size: 14px; }
        .empty-state {
            text-align: center; padding: 35px 16px;
            background: #f8fbff; border: 1px dashed #cbd8e8; border-radius: 12px;
        }
        .empty-state .empty-icon { font-size: 31px; margin-bottom: 10px; }
        .empty-state h4 { margin: 0 0 7px; color: #334155; font-size: 14px; }
        .empty-state p { margin: 0; color: var(--texto-suave); font-size: 12px; line-height: 1.6; }
        .bottom-note { color: #8290a4; font-size: 11px; text-align: center; margin: 24px 0 0; }

        @media (max-width: 1150px) {
            .sidebar { width: 225px; flex-basis: 225px; }
            .dashboard-grid { grid-template-columns: minmax(0, 1fr); }
            .topbar-note { display: none; }
        }
        @media (max-width: 760px) {
            .app { display: block; }
            .sidebar { width: 100%; min-height: auto; height: auto; padding: 13px 14px; }
            .brand { display: flex; align-items: center; justify-content: flex-start; gap: 12px; padding: 0 5px 12px; text-align: left; }
            .brand img { width: 135px; height: 48px; margin: 0; }
            .brand-caption { display: none; }
            .nav-label, .clinic-section, .sidebar-spacer { display: none; }
            .sidebar nav { display: flex; flex-wrap: wrap; gap: 6px; }
            .nav-link { flex: 1 1 auto; justify-content: center; padding: 10px 12px; margin: 0; font-size: 12px; }
            .nav-icon { width: auto; }
            .logout { margin-top: 9px; padding: 10px; font-size: 12px; }
            .main-content { padding: 20px 14px 28px; }
            .topbar { margin-bottom: 17px; padding-bottom: 16px; }
            .topbar h1 { font-size: 25px; }
            .welcome-banner { padding: 18px; border-radius: 14px; }
            .welcome-banner h2 { font-size: 17px; }
            .welcome-symbol { width: 45px; height: 45px; flex-basis: 45px; font-size: 23px; }
            .summary-grid { grid-template-columns: 1fr; gap: 10px; }
            .summary-card { padding: 14px 16px; }
            .card { padding: 18px 15px; }
            .dashboard-grid { grid-template-columns: minmax(0, 1fr); gap: 16px; }
        }
        @media (max-width: 420px) {
            .nav-link { flex-basis: 100%; justify-content: flex-start; }
            .appointment-item { flex-direction: column; }
            .topbar h1 { font-size: 22px; }
        }
    </style>
</head>
<body>
<div class="app">
    <aside class="sidebar">
        <div class="brand">
            <img src="img/logoblanco.png" alt="SaludClick">
            <div class="brand-caption">Tu salud, a un clic</div>
        </div>

        <div class="nav-label">Menú principal</div>
        <nav>
            <a href="panel_paciente.jsp" class="nav-link active"><span class="nav-icon">▦</span> Mis citas</a>
            <a href="perfil_paciente.jsp" class="nav-link"><span class="nav-icon">♙</span> Mi perfil</a>
            <a href="clinicas_postas.jsp" class="nav-link"><span class="nav-icon">✚</span> Clínicas y postas</a>
        </nav>

        <div class="clinic-section">
            <div class="nav-label">Clínicas aliadas</div>
            <div class="clinic-card"><img src="img/estable1.jpg" alt="Centro de Salud San Carlos"></div>
            <div class="clinic-card"><img src="img/estable2.jpg" alt="Clínica aliada"></div>
        </div>

        <div class="sidebar-spacer"></div>
        <a href="login.jsp" class="logout">↪ Cerrar sesión</a>
    </aside>

    <main class="main-content">
        <header class="topbar">
            <div>
                <div class="eyebrow">Área del paciente</div>
                <h1>¡Hola, <span><%= escaparHTML(nombrePaciente) %></span>!</h1>
            </div>
            <div class="topbar-note"><span class="online-dot"></span> Sistema de citas médicas</div>
        </header>

        <section class="welcome-banner">
            <div>
                <h2>Cuida de tu salud con SaludClick</h2>
                <p>Programa y consulta tus citas médicas desde un solo lugar.<br>Tu bienestar es nuestra prioridad.</p>
            </div>
            <div class="welcome-symbol">✚</div>
        </section>

        <section class="summary-grid">
            <div class="summary-card">
                <div class="summary-icon icon-blue">▦</div>
                <div><div class="summary-number"><%= citasRegistradas %></div><div class="summary-label">Tus citas registradas</div></div>
            </div>
            <div class="summary-card">
                <div class="summary-icon icon-green">✓</div>
                <div><div class="summary-number">Activa</div><div class="summary-label">Sesión actual</div></div>
            </div>
            <div class="summary-card">
                <div class="summary-icon icon-teal">♡</div>
                <div><div class="summary-number">24/7</div><div class="summary-label">Acceso a SaludClick</div></div>
            </div>
        </section>

        <section class="dashboard-grid">
            <div class="card">
                <div class="card-heading">
                    <div>
                        <h3>Agendar nueva cita</h3>
                        <p>Completa los datos para solicitar tu atención médica.</p>
                    </div>
                    <div class="section-icon">▦</div>
                </div>

                <form action="ProgramarCitaServlet" method="POST">
                    <!-- Se conserva para compatibilidad; el servidor debe validar el DNI usando la sesión. -->
                    <input type="hidden" name="numeroDocumento" value="<%= escaparHTML(dniSesion) %>">

                    <div class="field">
                        <label for="idEstablecimiento"><span class="field-number">1</span>Establecimiento de salud</label>
                        <select id="idEstablecimiento" onchange="cargarEspecialidades()" required>
                            <option value="">Selecciona un establecimiento</option>
                            <%
                                Connection conEst = null;
                                Statement stEst = null;
                                ResultSet rsEst = null;
                                try {
                                    conEst = ConexionDB.conectar();
                                    if (conEst != null) {
                                        stEst = conEst.createStatement();
                                        rsEst = stEst.executeQuery("SELECT id, nombre FROM establecimiento ORDER BY nombre");
                                        while (rsEst.next()) {
                            %>
                            <option value="<%= rsEst.getInt("id") %>"><%= escaparHTML(rsEst.getString("nombre")) %></option>
                            <%
                                        }
                                    }
                                } catch (Exception e) {
                                    application.log("Error al cargar establecimientos", e);
                                } finally {
                                    try { if (rsEst != null) rsEst.close(); } catch (Exception e) {}
                                    try { if (stEst != null) stEst.close(); } catch (Exception e) {}
                                    try { if (conEst != null) conEst.close(); } catch (Exception e) {}
                                }
                            %>
                        </select>
                    </div>

                    <div class="field">
                        <label for="especialidadSelect"><span class="field-number">2</span>Especialidad médica</label>
                        <select id="especialidadSelect" onchange="cargarMedicos()" disabled required>
                            <option value="">Primero elige un establecimiento</option>
                        </select>
                    </div>

                    <div class="field">
                        <label for="idMedico"><span class="field-number">3</span>Médico disponible</label>
                        <select id="idMedico" name="idMedico" disabled required>
                            <option value="">Primero elige una especialidad</option>
                        </select>
                    </div>

                    <div class="field">
                        <label for="fecha">Fecha de la cita</label>
                        <input type="date" id="fecha" name="fecha" required>
                        <div class="field-hint">Selecciona una fecha a partir de hoy.</div>
                    </div>

                    <div class="field">
                        <label for="hora">Horario disponible</label>
                        <select id="hora" name="hora" required>
                            <option value="">Selecciona un horario</option>
                            <option value="08:00:00">08:00 a. m.</option>
                            <option value="10:00:00">10:00 a. m.</option>
                            <option value="14:00:00">02:00 p. m.</option>
                            <option value="16:30:00">04:30 p. m.</option>
                        </select>
                    </div>

                    <button type="submit" class="submit-button">✓ Confirmar cita médica</button>
                </form>
            </div>

            <div class="card">
                <div class="card-heading">
                    <div>
                        <h3>Mis citas</h3>
                        <p>Las citas pendientes se muestran por separado de las atenciones anteriores.</p>
                    </div>
                    <div class="section-icon">♡</div>
                </div>

                <%
                    List<Map<String, String>> citasPendientes = new ArrayList<>();
                    List<Map<String, String>> citasHistorial = new ArrayList<>();
                    boolean errorCitas = false;
                    Connection conCitas = null;
                    PreparedStatement psCitas = null;
                    ResultSet rsCitas = null;
                    DateTimeFormatter formatoCita = DateTimeFormatter.ofPattern("dd/MM/yyyy");

                    try {
                        conCitas = ConexionDB.conectar();
                        if (conCitas == null) throw new SQLException("No se pudo conectar con la base de datos.");

                        String sqlCitas = "SELECT c.fecha_cita, c.hora_cita, c.estado, " +
                            "m.especialidad, m.nombre AS medico_nombre, e.nombre AS est_nombre " +
                            "FROM cita c " +
                            "INNER JOIN medico m ON c.id_medico = m.id " +
                            "LEFT JOIN establecimiento e ON m.id_establecimiento = e.id " +
                            "WHERE c.numero_documento = ? " +
                            "ORDER BY c.fecha_cita ASC, c.hora_cita ASC";

                        psCitas = conCitas.prepareStatement(sqlCitas);
                        psCitas.setString(1, dniSesion);
                        rsCitas = psCitas.executeQuery();

                        while (rsCitas.next()) {
                            java.sql.Date fechaSql = rsCitas.getDate("fecha_cita");
                            LocalDate fechaLocal = fechaSql != null ? fechaSql.toLocalDate() : LocalDate.MIN;
                            String fechaCita = fechaSql != null ? fechaLocal.format(formatoCita) : "Fecha no disponible";
                            String horaCita = rsCitas.getString("hora_cita");
                            if (horaCita != null && horaCita.length() >= 5) horaCita = horaCita.substring(0, 5);
                            String estadoCita = rsCitas.getString("estado");
                            if (estadoCita == null || estadoCita.trim().isEmpty()) estadoCita = "Sin estado";

                            boolean fechaPasada = fechaLocal.isBefore(LocalDate.now());
                            boolean atendida = "Atendida".equalsIgnoreCase(estadoCita);
                            boolean cancelada = "Cancelada".equalsIgnoreCase(estadoCita);
                            String estadoMostrar = estadoCita;
                            String claseEstado = "";
                            String colorBorde = "#2563eb";

                            if (atendida) {
                                claseEstado = "status-done";
                                colorBorde = "#10b981";
                            } else if (cancelada) {
                                claseEstado = "status-cancelled";
                                colorBorde = "#ef4444";
                            } else if (fechaPasada) {
                                // No afirmamos que fue atendida: solo indicamos que la fecha ya pasó.
                                estadoMostrar = "Fecha pasada · revisar estado";
                                claseEstado = "status-past";
                                colorBorde = "#d97706";
                            }

                            Map<String, String> cita = new HashMap<>();
                            cita.put("fecha", fechaCita);
                            cita.put("hora", horaCita == null ? "" : horaCita);
                            cita.put("especialidad", rsCitas.getString("especialidad"));
                            cita.put("medico", rsCitas.getString("medico_nombre"));
                            cita.put("establecimiento", rsCitas.getString("est_nombre"));
                            cita.put("estado", estadoMostrar);
                            cita.put("claseEstado", claseEstado);
                            cita.put("colorBorde", colorBorde);

                            if (!fechaPasada && !atendida && !cancelada) {
                                citasPendientes.add(cita);
                            } else {
                                citasHistorial.add(cita);
                            }
                        }
                        // Historial: primero las citas más recientes.
                        Collections.reverse(citasHistorial);
                    } catch (Exception e) {
                        application.log("Error al cargar citas del paciente", e);
                        errorCitas = true;
                    } finally {
                        try { if (rsCitas != null) rsCitas.close(); } catch (Exception e) {}
                        try { if (psCitas != null) psCitas.close(); } catch (Exception e) {}
                        try { if (conCitas != null) conCitas.close(); } catch (Exception e) {}
                    }
                %>

                <h4 class="appointments-subtitle">Próximas citas</h4>
                <div class="appointments-list">
                    <% if (errorCitas) { %>
                        <div class="empty-state">
                            <div class="empty-icon">⚠</div>
                            <h4>No se pudieron cargar las citas</h4>
                            <p>Inténtalo nuevamente más tarde.</p>
                        </div>
                    <% } else if (citasPendientes.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">♡</div>
                            <h4>No tienes citas pendientes</h4>
                            <p>Cuando programes una nueva cita, aparecerá en esta sección.</p>
                        </div>
                    <% } else { %>
                        <% for (Map<String, String> cita : citasPendientes) { %>
                            <article class="appointment-item" style="border-left-color: <%= cita.get("colorBorde") %>!important;">
                                <div class="appointment-info">
                                    <h4><%= escaparHTML(cita.get("especialidad")) %></h4>
                                    <p class="doctor-name">♙ Dr(a). <%= escaparHTML(cita.get("medico")) %></p>
                                    <p>✚ <%= escaparHTML(cita.get("establecimiento")) %></p>
                                    <p>▦ <%= escaparHTML(cita.get("fecha")) %> · <%= escaparHTML(cita.get("hora")) %></p>
                                </div>
                                <span class="status-badge <%= cita.get("claseEstado") %>"><%= escaparHTML(cita.get("estado")) %></span>
                            </article>
                        <% } %>
                    <% } %>
                </div>

                <h4 class="appointments-subtitle">Historial de citas</h4>
                <div class="appointments-list">
                    <% if (errorCitas) { %>
                        <div class="empty-state"><p>No se pudo cargar el historial de citas.</p></div>
                    <% } else if (citasHistorial.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">▦</div>
                            <h4>Aún no tienes citas anteriores</h4>
                            <p>Las citas atendidas, canceladas o con fecha pasada aparecerán aquí.</p>
                        </div>
                    <% } else { %>
                        <% for (Map<String, String> cita : citasHistorial) { %>
                            <article class="appointment-item" style="border-left-color: <%= cita.get("colorBorde") %>!important;">
                                <div class="appointment-info">
                                    <h4><%= escaparHTML(cita.get("especialidad")) %></h4>
                                    <p class="doctor-name">♙ Dr(a). <%= escaparHTML(cita.get("medico")) %></p>
                                    <p>✚ <%= escaparHTML(cita.get("establecimiento")) %></p>
                                    <p>▦ <%= escaparHTML(cita.get("fecha")) %> · <%= escaparHTML(cita.get("hora")) %></p>
                                </div>
                                <span class="status-badge <%= cita.get("claseEstado") %>"><%= escaparHTML(cita.get("estado")) %></span>
                            </article>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </section>

        <p class="bottom-note">SaludClick · Tu salud, a un clic. Cuida tus datos y cierra sesión al terminar.</p>
    </main>
</div>

<script>
    // Evita seleccionar fechas anteriores al día actual en el navegador.
    (function () {
        const fecha = document.getElementById("fecha");
        const hoy = new Date();
        const zonaLocal = new Date(hoy.getTime() - hoy.getTimezoneOffset() * 60000);
        fecha.min = zonaLocal.toISOString().slice(0, 10);
    })();

    // Los datos se codifican como JSON para evitar que comillas en nombres
    // rompan el JavaScript. Los valores proceden de la base de datos.
    const medicosData = [
        <%
            Connection conData = null;
            Statement stData = null;
            ResultSet rsData = null;
            boolean primero = true;

            try {
                conData = ConexionDB.conectar();
                if (conData != null) {
                    stData = conData.createStatement();
                    rsData = stData.executeQuery("SELECT id, nombre, especialidad, id_establecimiento FROM medico");

                    while (rsData.next()) {
                        if (!primero) out.print(",");
                        primero = false;
        %>
        {
            id: <%= rsData.getInt("id") %>,
            nombre: "<%= escaparHTML(rsData.getString("nombre")).replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>",
            esp: "<%= escaparHTML(rsData.getString("especialidad")).replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>",
            estId: <%= rsData.getInt("id_establecimiento") %>
        }
        <%
                    }
                }
            } catch (Exception e) {
                application.log("Error al cargar médicos para el formulario", e);
            } finally {
                try { if (rsData != null) rsData.close(); } catch (Exception e) {}
                try { if (stData != null) stData.close(); } catch (Exception e) {}
                try { if (conData != null) conData.close(); } catch (Exception e) {}
            }
        %>
    ];

    function cargarEspecialidades() {
        const estId = document.getElementById("idEstablecimiento").value;
        const espSelect = document.getElementById("especialidadSelect");
        const medSelect = document.getElementById("idMedico");

        espSelect.innerHTML = '<option value="">Selecciona una especialidad</option>';
        medSelect.innerHTML = '<option value="">Primero elige una especialidad</option>';
        medSelect.disabled = true;

        if (!estId) {
            espSelect.disabled = true;
            return;
        }

        const especialidades = [...new Set(
            medicosData.filter(m => String(m.estId) === estId).map(m => m.esp)
        )];

        especialidades.forEach(esp => {
            const opt = document.createElement("option");
            opt.value = esp;
            opt.textContent = esp;
            espSelect.appendChild(opt);
        });

        espSelect.disabled = especialidades.length === 0;
        if (especialidades.length === 0) {
            espSelect.innerHTML = '<option value="">No hay especialidades disponibles</option>';
        }
    }

    function cargarMedicos() {
        const estId = document.getElementById("idEstablecimiento").value;
        const espNombre = document.getElementById("especialidadSelect").value;
        const medSelect = document.getElementById("idMedico");

        medSelect.innerHTML = '<option value="">Selecciona un médico</option>';

        if (!estId || !espNombre) {
            medSelect.disabled = true;
            return;
        }

        const medicos = medicosData.filter(
            m => String(m.estId) === estId && m.esp === espNombre
        );

        medicos.forEach(m => {
            const opt = document.createElement("option");
            opt.value = m.id;
            opt.textContent = m.nombre;
            medSelect.appendChild(opt);
        });

        medSelect.disabled = medicos.length === 0;
        if (medicos.length === 0) {
            medSelect.innerHTML = '<option value="">No hay médicos disponibles</option>';
        }
    }
</script>
</body>
</html>
