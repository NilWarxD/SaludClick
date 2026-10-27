<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="Conexion.ConexionDB"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private boolean esTipo(String tipo, String buscado) {
        return tipo != null && tipo.toLowerCase(Locale.ROOT).contains(buscado);
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String dniSesion = (String) session.getAttribute("usuarioDni");
    if (!"PACIENTE".equals(session.getAttribute("rol")) || dniSesion == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombrePaciente = "";
    List<Map<String, Object>> establecimientos = new ArrayList<>();
    int totalMedicos = 0;
    int totalClinicas = 0;
    int totalPostas = 0;
    boolean errorCarga = false;

    try (Connection con = ConexionDB.conectar()) {
        if (con == null) throw new SQLException("No se pudo conectar con la base de datos.");

        try (PreparedStatement ps = con.prepareStatement(
                "SELECT nombre FROM paciente WHERE numero_documento = ?")) {
            ps.setString(1, dniSesion);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) nombrePaciente = rs.getString("nombre");
            }
        }

        String sql = "SELECT e.id, e.nombre, e.tipo, e.direccion, " +
                     "COUNT(m.id) AS total_medicos, " +
                     "GROUP_CONCAT(DISTINCT m.especialidad ORDER BY m.especialidad SEPARATOR ', ') AS especialidades " +
                     "FROM establecimiento e LEFT JOIN medico m ON m.id_establecimiento = e.id " +
                     "GROUP BY e.id, e.nombre, e.tipo, e.direccion " +
                     "ORDER BY e.tipo, e.nombre";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                int id = rs.getInt("id");
                String tipo = rs.getString("tipo");
                item.put("id", id);
                item.put("nombre", rs.getString("nombre"));
                item.put("tipo", tipo == null ? "Establecimiento" : tipo);
                item.put("direccion", rs.getString("direccion"));
                item.put("totalMedicos", rs.getInt("total_medicos"));
                item.put("especialidades", rs.getString("especialidades"));
                item.put("imagen", id == 1 ? "img/estable1.jpg" : (id == 2 ? "img/estable2.jpg" : "img/logo1.png"));
                establecimientos.add(item);
                totalMedicos += rs.getInt("total_medicos");
                if (esTipo(tipo, "clini")) totalClinicas++;
                if (esTipo(tipo, "posta")) totalPostas++;
            }
        }
    } catch (Exception e) {
        errorCarga = true;
        application.log("Error al cargar establecimientos de SaludClick", e);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Clínicas y Postas</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }
        :root { --azul: #1e3a8a; --azul-vivo: #2563eb; --fondo: #f1f5f9; --texto: #0f172a; --suave: #64748b; }
        body { display: flex; min-height: 100vh; background: var(--fondo); color: var(--texto); }
        .sidebar { width: 250px; background: var(--azul); color: white; padding: 24px 14px; display: flex; flex-direction: column; flex-shrink: 0; }
        .logo { width: 158px; max-width: 100%; display: block; margin: 0 auto 30px; }
        .sidebar a { display: block; padding: 12px 14px; border-radius: 8px; color: #dbeafe; text-decoration: none; font-weight: 600; margin-bottom: 7px; transition: background .18s ease; }
        .sidebar a:hover, .sidebar a.activo { background: #1d4ed8; color: #fff; }
        .sidebar .salir { margin-top: auto; background: #b91c1c; color: white; text-align: center; }
        .sidebar .salir:hover { background: #991b1b; }
        .contenido { flex: 1; min-width: 0; padding: 32px 38px 42px; }
        .encabezado { display: flex; justify-content: space-between; align-items: flex-end; gap: 20px; flex-wrap: wrap; margin-bottom: 24px; padding-bottom: 22px; border-bottom: 1px solid #dbe3ee; }
        .etiqueta { display: inline-flex; align-items: center; gap: 7px; padding: 6px 10px; background: #dbeafe; color: #1d4ed8; border-radius: 99px; font-size: 12px; font-weight: 800; letter-spacing: .04em; text-transform: uppercase; margin-bottom: 12px; }
        .encabezado h1 { font-size: clamp(25px, 2.3vw, 34px); line-height: 1.15; color: var(--texto); margin-bottom: 9px; }
        .encabezado p { color: var(--suave); line-height: 1.6; max-width: 680px; }
        .saludo { color: #1e40af; background: white; border: 1px solid #dbeafe; padding: 12px 16px; border-radius: 12px; font-weight: 700; box-shadow: 0 3px 10px rgba(15,23,42,.03); }
        .resumen { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; margin-bottom: 27px; }
        .resumen-card { background: white; border-radius: 14px; padding: 19px 21px; border: 1px solid #e2e8f0; box-shadow: 0 5px 15px rgba(15,23,42,.035); display: flex; align-items: center; gap: 15px; min-height: 103px; }
        .resumen-icono { flex-shrink: 0; display: grid; place-items: center; width: 48px; height: 48px; border-radius: 13px; background: #dbeafe; font-size: 23px; }
        .resumen-card strong { display: block; font-size: 27px; line-height: 1.15; color: var(--azul); margin-bottom: 4px; }
        .resumen-card span { color: var(--suave); font-size: 13px; }
        .barra-herramientas { display: flex; justify-content: space-between; align-items: center; gap: 15px; flex-wrap: wrap; margin-bottom: 18px; }
        .barra-herramientas h2 { color: var(--azul); font-size: 21px; }
        .buscador { display: flex; align-items: center; gap: 9px; background: white; border: 1px solid #cbd5e1; border-radius: 10px; padding: 0 13px; min-width: min(100%, 310px); }
        .buscador span { font-size: 17px; }
        .buscador input { width: 100%; border: 0; outline: 0; padding: 12px 0; color: var(--texto); background: transparent; font-size: 14px; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 22px; }
        .card { background: white; border-radius: 16px; overflow: hidden; border: 1px solid #e2e8f0; box-shadow: 0 6px 18px rgba(15,23,42,.045); transition: transform .18s ease, box-shadow .18s ease; }
        .card:hover { transform: translateY(-3px); box-shadow: 0 12px 25px rgba(15,23,42,.08); }
        .card-cabecera { display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #eaf2ff, #f8fbff); min-height: 150px; padding: 22px; border-bottom: 1px solid #e7eef7; }
        .card-cabecera img { width: 100%; height: 112px; object-fit: contain; }
        .card-cuerpo { padding: 23px; }
        .badge { display: inline-flex; align-items: center; padding: 6px 11px; border-radius: 99px; background: #e0f2fe; color: #0369a1; font-weight: 800; font-size: 12px; margin-bottom: 11px; }
        .card h3 { color: var(--azul); font-size: 21px; margin-bottom: 12px; line-height: 1.3; }
        .ubicacion { display: flex; gap: 9px; align-items: flex-start; color: #475569; font-size: 14px; line-height: 1.5; margin-bottom: 19px; }
        .mini-datos { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; margin-bottom: 20px; }
        .mini-dato { padding: 13px; background: #f8fafc; border: 1px solid #e8eef5; border-radius: 10px; }
        .mini-dato .label { display: block; font-size: 12px; color: var(--suave); margin-bottom: 5px; }
        .mini-dato strong { color: #1e293b; font-size: 17px; }
        .especialidades { border-top: 1px solid #e2e8f0; padding-top: 16px; }
        .especialidades h4 { font-size: 13px; color: #475569; margin-bottom: 10px; }
        .chips { display: flex; flex-wrap: wrap; gap: 7px; }
        .chip { font-size: 12px; font-weight: 600; padding: 6px 9px; color: #1d4ed8; background: #eff6ff; border-radius: 7px; border: 1px solid #dbeafe; }
        .sin-datos { font-size: 13px; color: var(--suave); }
        .card-acciones { display: flex; gap: 10px; padding: 0 23px 23px; }
        .btn { display: inline-flex; justify-content: center; align-items: center; gap: 7px; border-radius: 9px; padding: 12px 15px; text-decoration: none; font-weight: 800; font-size: 13px; transition: background .18s ease; }
        .btn-principal { flex: 1; background: #10b981; color: white; }
        .btn-principal:hover { background: #059669; }
        .vacio, .error { background: white; padding: 32px; border-radius: 14px; text-align: center; border: 1px dashed #cbd5e1; color: var(--suave); line-height: 1.7; }
        .vacio h3 { color: var(--azul); margin-bottom: 8px; }
        .error { background: #fef2f2; color: #991b1b; border-color: #fecaca; }
        .pie { color: var(--suave); font-size: 12px; text-align: center; margin-top: 25px; line-height: 1.6; }
        @media (max-width: 1050px) { .grid { grid-template-columns: 1fr; } .contenido { padding: 25px; } }
        @media (max-width: 760px) { body { flex-direction: column; } .sidebar { width: 100%; flex-direction: row; align-items: center; flex-wrap: wrap; gap: 6px; padding: 12px; } .logo { width: 105px; margin: 0 12px 0 0; } .sidebar a { margin-bottom: 0; padding: 10px; font-size: 13px; } .sidebar .salir { margin-left: auto; margin-top: 0; } .contenido { padding: 20px 15px; } .resumen { grid-template-columns: 1fr; gap: 11px; } .resumen-card { min-height: 82px; } .mini-datos { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 440px) { .card-cuerpo { padding: 18px; } .card-acciones { padding: 0 18px 18px; } .mini-datos { grid-template-columns: 1fr; } .saludo { width: 100%; } }
    </style>
</head>
<body>
    <aside class="sidebar">
        <img class="logo" src="img/logoblanco.png" alt="SaludClick">
        <a href="panel_paciente.jsp">📅 Mis Citas</a>
        <a href="perfil_paciente.jsp">👤 Mi Perfil</a>
        <a href="clinicas_postas.jsp" class="activo">🏥 Clínicas y Postas</a>
        <a href="LogoutServlet" class="salir">Cerrar Sesión</a>
    </aside>

    <main class="contenido">
        <header class="encabezado">
            <div>
                <span class="etiqueta">🏥 Red de atención</span>
                <h1>Establecimientos de salud afiliados</h1>
                <p>Explora las clínicas y postas disponibles, revisa sus especialidades y agenda una cita desde tu panel de paciente.</p>
            </div>
            <div class="saludo">Hola<%= nombrePaciente == null || nombrePaciente.trim().isEmpty() ? "" : ", " + esc(nombrePaciente) %> 👋</div>
        </header>

        <% if (errorCarga) { %>
            <div class="error">No se pudieron cargar los establecimientos. Comprueba la conexión con la base de datos e inténtalo nuevamente.</div>
        <% } else { %>
            <section class="resumen">
                <div class="resumen-card">
                    <div class="resumen-icono">🏥</div>
                    <div><strong><%= establecimientos.size() %></strong><span>Establecimientos disponibles</span></div>
                </div>
                <div class="resumen-card">
                    <div class="resumen-icono">👨‍⚕️</div>
                    <div><strong><%= totalMedicos %></strong><span>Profesionales registrados</span></div>
                </div>
                <div class="resumen-card">
                    <div class="resumen-icono">📍</div>
                    <div><strong><%= totalClinicas %> / <%= totalPostas %></strong><span>Clínicas / postas</span></div>
                </div>
            </section>

            <div class="barra-herramientas">
                <h2>Encuentra tu establecimiento</h2>
                <label class="buscador">
                    <span>🔎</span>
                    <input type="search" id="buscarEstablecimiento" placeholder="Buscar por nombre, tipo o especialidad…" autocomplete="off">
                </label>
            </div>

            <% if (establecimientos.isEmpty()) { %>
                <div class="vacio">
                    <h3>Aún no hay establecimientos registrados</h3>
                    <p>Cuando se agreguen establecimientos a SaludClick, aparecerán aquí.</p>
                </div>
            <% } else { %>
                <section class="grid" id="gridEstablecimientos">
                    <% for (Map<String, Object> item : establecimientos) {
                        String nombre = String.valueOf(item.get("nombre"));
                        String tipo = String.valueOf(item.get("tipo"));
                        String direccion = item.get("direccion") == null ? "Dirección no registrada" : String.valueOf(item.get("direccion"));
                        String especialidades = item.get("especialidades") == null ? "" : String.valueOf(item.get("especialidades"));
                        int cantidadMedicos = ((Number)item.get("totalMedicos")).intValue();
                        String imagen = String.valueOf(item.get("imagen"));
                        String textoBusqueda = nombre + " " + tipo + " " + direccion + " " + especialidades;
                    %>
                        <article class="card establecimiento-card" data-search="<%= esc(textoBusqueda) %>">
                            <div class="card-cabecera">
                                <img src="<%= esc(imagen) %>" alt="Imagen de <%= esc(nombre) %>" onerror="this.onerror=null;this.src='img/logo1.png';">
                            </div>
                            <div class="card-cuerpo">
                                <span class="badge"><%= esc(tipo) %></span>
                                <h3><%= esc(nombre) %></h3>
                                <p class="ubicacion"><span>📍</span><span><%= esc(direccion) %></span></p>
                                <div class="mini-datos">
                                    <div class="mini-dato"><span class="label">Profesionales</span><strong><%= cantidadMedicos %></strong></div>
                                    <div class="mini-dato"><span class="label">Especialidades</span><strong><%= especialidades.trim().isEmpty() ? "0" : especialidades.split(",").length %></strong></div>
                                </div>
                                <div class="especialidades">
                                    <h4>Especialidades disponibles</h4>
                                    <% if (especialidades.trim().isEmpty()) { %>
                                        <p class="sin-datos">No hay especialidades registradas todavía.</p>
                                    <% } else { %>
                                        <div class="chips">
                                            <% for (String esp : especialidades.split(",")) { %>
                                                <span class="chip"><%= esc(esp.trim()) %></span>
                                            <% } %>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                            <div class="card-acciones">
                                <a class="btn btn-principal" href="panel_paciente.jsp">📅 Agendar cita en SaludClick</a>
                            </div>
                        </article>
                    <% } %>
                </section>
                <div id="sinResultados" class="vacio" style="display:none; margin-top:18px;">
                    <h3>No encontramos coincidencias</h3>
                    <p>Prueba con otro nombre, tipo de establecimiento o especialidad.</p>
                </div>
            <% } %>
        <% } %>

        <p class="pie">La información mostrada corresponde a los datos registrados en SaludClick. Confirma los datos del establecimiento antes de acudir.</p>
    </main>

    <script>
        const buscador = document.getElementById('buscarEstablecimiento');
        if (buscador) {
            buscador.addEventListener('input', function () {
                const texto = this.value.trim().toLocaleLowerCase('es');
                const tarjetas = Array.from(document.querySelectorAll('.establecimiento-card'));
                let visibles = 0;
                tarjetas.forEach(function (tarjeta) {
                    const contenido = (tarjeta.dataset.search || '').toLocaleLowerCase('es');
                    const coincide = contenido.includes(texto);
                    tarjeta.style.display = coincide ? '' : 'none';
                    if (coincide) visibles++;
                });
                const sinResultados = document.getElementById('sinResultados');
                if (sinResultados) sinResultados.style.display = (tarjetas.length > 0 && visibles === 0) ? 'block' : 'none';
            });
        }
    </script>
</body>
</html>
