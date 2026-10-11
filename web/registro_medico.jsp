<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, Conexion.ConexionDB"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Registrar médico</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }

        body { background-color: #f1f5f9; min-height: 100vh; display: flex; justify-content: center; align-items: flex-start; padding: 40px 20px; }

        .form-box { width: 100%; max-width: 560px; background: #ffffff; border-radius: 16px; padding: 40px; box-shadow: 0 4px 24px rgba(15, 23, 42, 0.08); }

        .logo-container { text-align: center; margin-bottom: 10px; }
        .logo-container img { width: 220px; height: auto; object-fit: contain; }

        h2 { color: #000000; font-size: 2rem; text-align: center; margin-bottom: 8px; font-weight: 700; }
        .subtitulo { text-align: center; color: #64748b; font-size: 1.05rem; margin-bottom: 28px; }

        label { display: block; font-weight: 600; margin-bottom: 8px; color: #475569; font-size: 1.1rem; }

        .campo { width: 100%; padding: 14px 16px; margin-bottom: 22px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 1.05rem; outline: none; background: #ffffff; }
        .campo:focus { border-color: #2563eb; }

        button { width: 100%; background-color: #1a56db; color: white; padding: 14px; border: none; border-radius: 30px; font-size: 1.3rem; font-weight: bold; cursor: pointer; transition: background 0.2s; margin-top: 6px; }
        button:hover { background-color: #1e429f; }

        .mensaje { border-radius: 10px; padding: 14px 18px; margin-bottom: 24px; font-size: 1.05rem; font-weight: 600; text-align: center; }
        .mensaje-error { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .mensaje-ok { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }

        .volver { margin-top: 28px; text-align: center; font-size: 1.05rem; }
        .volver a { color: #1a56db; text-decoration: none; font-weight: 700; }
    </style>
</head>
<body>

    <div class="form-box">

        <div class="logo-container">
            <img src="img/logo1.png" alt="Logo SaludClick">
        </div>

        <h2>Registrar médico</h2>
        <p class="subtitulo">Agrega un profesional para que los pacientes puedan programar citas con él.</p>

        <%
            String ok = request.getParameter("ok");
            String error = request.getParameter("error");
        %>
        <% if ("1".equals(ok)) { %>
            <div class="mensaje mensaje-ok">Médico registrado correctamente.</div>
        <% } else if ("1".equals(error)) { %>
            <div class="mensaje mensaje-error">Completa el nombre y la especialidad.</div>
        <% } else if ("2".equals(error)) { %>
            <div class="mensaje mensaje-error">Selecciona un establecimiento válido.</div>
        <% } else if ("3".equals(error)) { %>
            <div class="mensaje mensaje-error">No se pudo guardar el médico. Inténtalo de nuevo.</div>
        <% } %>

        <form action="RegistrarMedicoServlet" method="POST">

            <label for="nombre">Nombre completo:</label>
            <input type="text" id="nombre" name="nombre" class="campo" required maxlength="100"
                   placeholder="Ej: Dra. Ana Espinoza">

            <label for="especialidad">Especialidad:</label>
            <input type="text" id="especialidad" name="especialidad" class="campo" required maxlength="100"
                   placeholder="Ej: Medicina General">

            <label for="idEstablecimiento">Establecimiento:</label>
            <select id="idEstablecimiento" name="idEstablecimiento" class="campo" required>
                <option value="">Selecciona un establecimiento</option>
                <%
                    // Se cargan los establecimientos desde la base de datos
                    try (Connection con = ConexionDB.conectar()) {
                        if (con != null) {
                            try (PreparedStatement ps = con.prepareStatement("SELECT id, nombre FROM establecimiento ORDER BY nombre");
                                 ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                %>
                <option value="<%= rs.getInt("id") %>"><%= rs.getString("nombre") %></option>
                <%
                                }
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                %>
            </select>

            <button type="submit">Guardar médico</button>
        </form>

        <div class="volver">
            <a href="login.jsp">Volver al inicio de sesión</a>
        </div>
    </div>

</body>
</html>