<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page import="java.sql.*, Conexion.ConexionDB"%>
<%!
    
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    // Devuelve el resultado de un SELECT COUNT(*)
    private static int contar(Connection con, String sql) {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
%>
<%

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Solo entra el administrador
    if (!"ADMIN".equals(session.getAttribute("rol"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombreAdmin = (String) session.getAttribute("adminNombre");

    int totalMedicos = 0, totalPacientes = 0, citasProgramadas = 0, totalEstablecimientos = 0;
    try (Connection con = ConexionDB.conectar()) {
        if (con != null) {
            totalMedicos = contar(con, "SELECT COUNT(*) FROM medico");
            totalPacientes = contar(con, "SELECT COUNT(*) FROM paciente");
            citasProgramadas = contar(con, "SELECT COUNT(*) FROM cita WHERE estado = 'Programada'");
            totalEstablecimientos = contar(con, "SELECT COUNT(*) FROM establecimiento");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Panel del administrador</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }
        body { display: flex; min-height: 100vh; background: #f1f5f9; color: #1e293b; }

        .sidebar { width: 250px; background: #1e3a8a; padding: 24px 14px; display: flex; flex-direction: column; flex-shrink: 0; }
        .sidebar img { width: 150px; display: block; margin: 0 auto 28px; }
        .sidebar .item { display: block; padding: 12px 14px; border-radius: 8px; color: #dbeafe; text-decoration: none; font-weight: 600; margin-bottom: 6px; }
        .sidebar .item:hover { background: rgba(255, 255, 255, 0.12); }
        .sidebar .item.activo { background: #1a56db; color: #ffffff; }
        .sidebar .salir { margin-top: auto; background: #b91c1c; color: #ffffff; text-align: center; padding: 12px; border-radius: 8px; text-decoration: none; font-weight: 700; }
        .sidebar .salir:hover { background: #991b1b; }

        .contenido { flex: 1; padding: 32px 40px; min-width: 0; }
        .contenido h1 { font-size: 2rem; margin-bottom: 6px; }
        .contenido .rol { color: #64748b; margin-bottom: 28px; padding-bottom: 18px; border-bottom: 1px solid #e2e8f0; }

        .resumen { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-bottom: 32px; }
        .dato { background: #ffffff; border-radius: 12px; padding: 20px 22px; border-left: 5px solid #1a56db; }
        .dato strong { display: block; font-size: 2.2rem; color: #1e3a8a; line-height: 1.1; }
        .dato span { color: #64748b; font-size: 1rem; }

        .acciones { background: #ffffff; border-radius: 12px; padding: 26px; max-width: 640px; }
        .acciones h2 { font-size: 1.3rem; color: #1e3a8a; margin-bottom: 8px; }
        .acciones p { color: #475569; margin-bottom: 18px; }
        .boton { display: inline-block; background: #10b981; color: #ffffff; padding: 12px 24px; border-radius: 10px; text-decoration: none; font-weight: 700; }
        .boton:hover { background: #059669; }

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
        <a class="item activo" href="panel_admin.jsp">Inicio</a>
        <a class="item" href="registro_medico.jsp">Registrar médico</a>
        <a class="salir" href="LogoutServlet">Cerrar sesión</a>
    </nav>

    <main class="contenido">
        <h1>Bienvenido(a), <%= esc(nombreAdmin) %></h1>
        <p class="rol">Panel del administrador</p>

        <section class="resumen">
            <div class="dato"><strong><%= totalMedicos %></strong><span>Médicos registrados</span></div>
            <div class="dato"><strong><%= totalPacientes %></strong><span>Pacientes registrados</span></div>
            <div class="dato"><strong><%= citasProgramadas %></strong><span>Citas programadas</span></div>
            <div class="dato"><strong><%= totalEstablecimientos %></strong><span>Establecimientos</span></div>
        </section>

        <section class="acciones">
            <h2>Registrar un médico</h2>
            <p>Agrega un profesional con su documento y contraseña para que pueda iniciar sesión y ver sus citas.</p>
            <a class="boton" href="registro_medico.jsp">Registrar médico</a>
        </section>
    </main>

</body>
</html>