<%@page import="java.sql.*"%>
<%@page import="Conexion.ConexionDB"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String dniSesion = (String) session.getAttribute("usuarioDni");
    if (dniSesion == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>SaludClick - Establecimientos</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f1f5f9; display: flex; min-height: 100vh; margin:0; }
        .sidebar { width: 260px; background-color: #1e3a8a; color: white; padding: 30px 20px; display: flex; flex-direction: column; }
        .sidebar h2 { font-size: 1.5rem; margin-bottom: 40px; text-align: center; }
        .sidebar a { color: #93c5fd; text-decoration: none; padding: 12px 15px; border-radius: 8px; margin-bottom: 10px; font-weight: 600; }
        .sidebar a.active { background-color: #1d4ed8; color: white; }
        .main-content { flex: 1; padding: 40px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .card h3 { color: #1e3a8a; margin-bottom: 10px; }
        .badge { display: inline-block; padding: 4px 10px; background: #e0f2fe; color: #0369a1; border-radius: 20px; font-size: 0.85rem; font-weight: bold; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>🌐 SaludClick</h2>
        <a href="panel_paciente.jsp">📅 Mis Citas</a>
        <a href="perfil_paciente.jsp">👤 Mi Perfil</a>
        <a href="#" class="active">🏥 Clínicas y Postas</a>
        <a href="login.jsp">Cerrar Sesión</a>
    </div>
    <div class="main-content">
        <h2 style="color:#0f172a; margin-bottom:30px;">Establecimientos de Salud Afiliados</h2>
        <div class="grid">
            <%
                try {
                    Connection con = ConexionDB.conectar();
                    Statement st = con.createStatement();
                    ResultSet rs = st.executeQuery("SELECT * FROM establecimientos ORDER BY tipo, nombre");
                    while(rs.next()) {
            %>
                        <div class="card">
                            <span class="badge"><%= rs.getString("tipo") %></span>
                            <h3><%= rs.getString("nombre") %></h3>
                            <p style="color:#64748b;">📍 <%= rs.getString("direccion") %></p>
                        </div>
            <%
                    }
                    rs.close(); st.close(); con.close();
                } catch(Exception e) {}
            %>
        </div>
    </div>
</body>
</html>

