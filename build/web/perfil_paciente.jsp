<%@page import="java.sql.*"%>
<%@page import="Conexion.ConexionDB"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String dniSesion = (String) session.getAttribute("usuarioDni");
    if (dniSesion == null) { response.sendRedirect("login.jsp"); return; }

    String nombres = "", apellidos = "", telefono = "", email = "", tipoDoc = "";
    try {
        Connection con = ConexionDB.conectar();
        PreparedStatement ps = con.prepareStatement("SELECT * FROM paciente WHERE numero_documento = ?");
        ps.setString(1, dniSesion);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            nombres = rs.getString("nombre");
            apellidos = rs.getString("apellido");
            telefono = rs.getString("telefono");
            email = rs.getString("email");
            tipoDoc = rs.getString("tipo_documento");
        }
        rs.close(); ps.close(); con.close();
    } catch(Exception e) {}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>SaludClick - Mi Perfil</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f1f5f9; display: flex; min-height: 100vh; margin:0; }
        .sidebar { width: 260px; background-color: #1e3a8a; color: white; padding: 30px 20px; display: flex; flex-direction: column; }
        .sidebar h2 { font-size: 1.5rem; margin-bottom: 40px; text-align: center; }
        .sidebar a { color: #93c5fd; text-decoration: none; padding: 12px 15px; border-radius: 8px; margin-bottom: 10px; font-weight: 600; }
        .sidebar a.active { background-color: #1d4ed8; color: white; }
        .main-content { flex: 1; padding: 40px; }
        .card { background: white; padding: 40px; border-radius: 16px; max-width: 600px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin: 0 auto; }
        h2 { color: #1e3a8a; margin-bottom: 20px; }
        p { font-size: 1.1rem; margin-bottom: 15px; color: #475569; }
        strong { color: #0f172a; }
        .btn-volver { display: inline-block; margin-top: 25px; padding: 12px 20px; background: #2563eb; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>🌐 SaludClick</h2>
        <a href="panel_paciente.jsp">📅 Mis Citas</a>
        <a href="#" class="active">👤 Mi Perfil</a>
        <a href="clinicas_postas.jsp">🏥 Clínicas y Postas</a>
        <a href="login.jsp">Cerrar Sesión</a>
    </div>
    <div class="main-content">
        <div class="card">
            <h2>Mis Datos Personales</h2>
            <p><strong>Tipo de Documento:</strong> <%= tipoDoc %></p>
            <p><strong>Número de Documento:</strong> <%= dniSesion %></p>
            <p><strong>Nombres:</strong> <%= nombres %></p>
            <p><strong>Apellidos:</strong> <%= apellidos %></p>
            <p><strong>Teléfono:</strong> <%= (telefono != null ? telefono : "No registrado") %></p>
            <p><strong>Correo Electrónico:</strong> <%= (email != null ? email : "No registrado") %></p>
            <a href="panel_paciente.jsp" class="btn-volver">Volver a Mis Citas</a>
        </div>
    </div>
</body>
</html>

