<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<%@page import="java.sql.*, Conexion.ConexionDB"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
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

    String ok = request.getParameter("ok");
    String error = request.getParameter("error");
    String mensajeError = null;

    if ("1".equals(error)) mensajeError = "Completa todos los campos obligatorios.";
    else if ("2".equals(error)) mensajeError = "Selecciona un establecimiento válido.";
    else if ("3".equals(error)) mensajeError = "No se pudo guardar el médico. Inténtalo de nuevo.";
    else if ("4".equals(error)) mensajeError = "Ese documento ya está registrado en el sistema.";
    else if ("5".equals(error)) mensajeError = "La contraseña debe tener al menos 6 caracteres.";
    else if ("6".equals(error)) mensajeError = "El documento no es válido. El DNI debe tener 8 dígitos.";
    else if ("7".equals(error)) mensajeError = "El correo o el teléfono no tienen un formato válido.";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Registrar médico</title>
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
        .contenido .subtitulo { color: #64748b; margin-bottom: 24px; }

        .formulario { background: #ffffff; border-radius: 12px; padding: 30px; max-width: 760px; }

        .fila { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .campo-grupo { margin-bottom: 20px; min-width: 0; }
        label { display: block; font-weight: 600; margin-bottom: 7px; color: #475569; font-size: 1rem; }
        .opcional { font-weight: 400; color: #94a3b8; }

        .control { width: 100%; padding: 13px 15px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 1.05rem; outline: none; background: #ffffff; }
        .control:focus { border-color: #2563eb; }

        .documento { display: flex; border: 1.5px solid #cbd5e1; border-radius: 10px; overflow: hidden; }
        .documento:focus-within { border-color: #2563eb; }
        .documento select { border: none; border-right: 1.5px solid #cbd5e1; padding: 13px 12px; font-size: 1.05rem; font-weight: 600; background: #ffffff; outline: none; cursor: pointer; }
        .documento input { border: none; flex: 1; min-width: 0; padding: 13px 15px; font-size: 1.05rem; outline: none; }

        .guardar { background: #10b981; color: #ffffff; border: none; border-radius: 10px; padding: 14px 32px; font-size: 1.15rem; font-weight: 700; cursor: pointer; }
        .guardar:hover { background: #059669; }

        .mensaje { border-radius: 10px; padding: 14px 18px; margin-bottom: 22px; font-weight: 600; max-width: 760px; }
        .mensaje-error { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .mensaje-ok { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }

        @media (max-width: 800px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; flex-direction: row; flex-wrap: wrap; align-items: center; gap: 8px; padding: 14px; }
            .sidebar img { width: 110px; margin: 0 12px 0 0; }
            .sidebar .item { margin-bottom: 0; }
            .sidebar .salir { margin-top: 0; margin-left: auto; padding: 10px 16px; }
            .contenido { padding: 24px 18px; }
            .fila { grid-template-columns: 1fr; gap: 0; }
        }
    </style>
</head>
<body>

    <nav class="sidebar">
        <img src="img/logoblanco.png" alt="SaludClick">
        <a class="item" href="panel_admin.jsp">Inicio</a>
        <a class="item activo" href="registro_medico.jsp">Registrar médico</a>
        <a class="salir" href="LogoutServlet">Cerrar sesión</a>
    </nav>

    <main class="contenido">
        <h1>Registrar médico</h1>
        <p class="subtitulo">El médico iniciará sesión con su documento y la contraseña que le asignes aquí.</p>

        <% if ("1".equals(ok)) { %>
            <div class="mensaje mensaje-ok">Médico registrado correctamente.</div>
        <% } else if (mensajeError != null) { %>
            <div class="mensaje mensaje-error"><%= esc(mensajeError) %></div>
        <% } %>

        <form class="formulario" action="RegistrarMedicoServlet" method="POST">

            <div class="campo-grupo">
                <label for="numeroDocumento">Documento de identidad:</label>
                <div class="documento">
                    <select name="tipoDocumento" aria-label="Tipo de documento">
                        <option value="DNI">DNI</option>
                        <option value="CE">C.E.</option>
                        <option value="PASAPORTE">Pasaporte</option>
                    </select>
                    <input type="text" id="numeroDocumento" name="numeroDocumento" required maxlength="20"
                           placeholder="Nro de documento">
                </div>
            </div>

            <div class="campo-grupo">
                <label for="nombre">Nombre completo:</label>
                <input type="text" id="nombre" name="nombre" class="control" required maxlength="100"
                       placeholder="Ej: Dra. Ana Espinoza">
            </div>

            <div class="fila">
                <div class="campo-grupo">
                    <label for="especialidad">Especialidad:</label>
                    <input type="text" id="especialidad" name="especialidad" class="control" required maxlength="100"
                           placeholder="Ej: Medicina General">
                </div>

                <div class="campo-grupo">
                    <label for="idEstablecimiento">Establecimiento:</label>
                    <select id="idEstablecimiento" name="idEstablecimiento" class="control" required>
                        <option value="">Selecciona un establecimiento</option>
                        <%
                            try (Connection con = ConexionDB.conectar()) {
                                if (con != null) {
                                    try (PreparedStatement ps = con.prepareStatement("SELECT id, nombre FROM establecimiento ORDER BY nombre");
                                         ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                        %>
                        <option value="<%= rs.getInt("id") %>"><%= esc(rs.getString("nombre")) %></option>
                        <%
                                        }
                                    }
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>
            </div>

            <div class="fila">
                <div class="campo-grupo">
                    <label for="email">Correo <span class="opcional">(opcional)</span>:</label>
                    <input type="email" id="email" name="email" class="control" maxlength="100"
                           placeholder="medico@correo.com">
                </div>

                <div class="campo-grupo">
                    <label for="telefono">Teléfono <span class="opcional">(opcional)</span>:</label>
                    <input type="tel" id="telefono" name="telefono" class="control" maxlength="20"
                           placeholder="999999999">
                </div>
            </div>

            <div class="campo-grupo">
                <label for="password">Contraseña (mínimo 6 caracteres):</label>
                <input type="password" id="password" name="password" class="control" required minlength="6" maxlength="100"
                       placeholder="Contraseña de acceso del médico" autocomplete="new-password">
            </div>

            <button type="submit" class="guardar">Guardar médico</button>
        </form>
    </main>

</body>
</html>