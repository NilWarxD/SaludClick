<%@page import="java.sql.Connection"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="Conexion.ConexionDB"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
        conNom = Conexion.ConexionDB.conectar();
        // Columna en singular: nombre
        String sqlNom = "SELECT nombre FROM paciente WHERE numero_documento = ?";
        psNom = conNom.prepareStatement(sqlNom);
        psNom.setString(1, dniSesion);
        rsNom = psNom.executeQuery();
        if (rsNom.next()) {
            nombrePaciente = rsNom.getString("nombre");
        }
    } catch(Exception e) {
        nombrePaciente = "Paciente";
    } finally {
        if(rsNom != null) rsNom.close();
        if(psNom != null) psNom.close();
        if(conNom != null) conNom.close();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Panel del Paciente</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }
        body { background-color: #f1f5f9; color: #1e293b; display: flex; height: 100vh; overflow: hidden; }
        
        /* Barra Lateral Izquierda */
        .sidebar { width: 280px; background-color: #1e3a8a; color: white; padding: 20px 15px; display: flex; flex-direction: column; height: 100vh; overflow-y: auto; }
        .sidebar h2 { font-size: 1.5rem; margin-bottom: 20px; text-align: center; font-weight: 700; }
        .sidebar a { color: #93c5fd; text-decoration: none; padding: 10px 14px; border-radius: 8px; margin-bottom: 8px; font-weight: 600; transition: all 0.2s; }
        .sidebar a.active, .sidebar a:hover { background-color: #1d4ed8; color: white; }
        .sidebar .logout { margin-top: auto; background-color: #b91c1c; color: white; text-align: center; padding: 12px 14px; font-size: 1.3rem; font-weight: 600; }
        .sidebar .logout:hover { background-color: #991b1b; }

        /* Tarjetas de Establecimientos en la barra lateral */
        .sidebar-est-title { font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px; color: #93c5fd; margin: 15px 0 8px 5px; font-weight: 700; }
        .est-card-sidebar { background: #ffffff; border-radius: 10px; overflow: hidden; margin-bottom: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border: 1px solid rgba(255, 255, 255, 0.2); }
        .est-card-sidebar img { width: 100%; height: 65px; object-fit: cover; display: block; }
        .est-card-sidebar span { display: block; font-size: 0.8rem; font-weight: 700; color: #1e3a8a; text-align: center; padding: 6px 4px; background: #f8fafc; }

        /* Contenedor Principal Derecho */
        .main-content { flex: 1; padding: 25px 40px; height: 100vh; overflow-y: auto; }
        
        /* Bienvenida más grande y destacada */
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 2px solid #e2e8f0; padding-bottom: 15px; }
        .header h1 { font-size: 2.4rem; color: #0f172a; font-weight: 700; }
        
        /* Grid con altura estirada para mantener uniformidad */
        .dashboard-grid { display: grid; grid-template-columns: 1.3fr 1fr; gap: 25px; padding-bottom: 40px; align-items: stretch; }
        @media (max-width: 1024px) { .dashboard-grid { grid-template-columns: 1fr; } }

        /* Tarjetas contenedoras en formato flex para estirarse al fondo */
        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display: flex; flex-direction: column; justify-content: space-between; }
        .card h3 { color: #1e3a8a; font-size: 1.4rem; margin-bottom: 20px; border-bottom: 1px solid #f1f5f9; padding-bottom: 10px; }

        /* Formulario ampliado y adaptado para llenar el espacio vertical */
        form { display: flex; flex-direction: column; flex: 1; justify-content: space-between; }
        label { display: block; font-weight: 700; margin-bottom: 8px; color: #334155; font-size: 1.05rem; }
        select, input { width: 100%; padding: 16px 18px; margin-bottom: 18px; border: 1.5px solid #cbd5e1; border-radius: 10px; font-size: 1.15rem; outline: none; background-color: #fff; color: #0f172a; }
        select:focus, input:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12); }
        
        button { width: 100%; background-color: #10b981; color: white; padding: 18px; border: none; border-radius: 10px; font-size: 1.25rem; font-weight: bold; cursor: pointer; transition: background 0.2s; margin-top: auto; }
        button:hover { background-color: #059669; }

        /* Estilos de Próximas Citas */
        .appointment-item { background: #f8fafc; border-left: 5px solid #2563eb; padding: 16px; border-radius: 0 8px 8px 0; margin-bottom: 14px; display: flex; justify-content: space-between; align-items: center; }
        .appointment-info h4 { color: #1e293b; font-size: 1.1rem; }
        .appointment-info p { color: #64748b; font-size: 0.95rem; margin-top: 4px; }
        .status-badge { background-color: #dbeafe; color: #1e40af; padding: 6px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 700; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2><img src="img/logoblanco.png" alt="SaludClick Logo" style="width: 170px; "></h2>
        <a href="panel_paciente.jsp" class="active">📅 Mis Citas</a>
        <a href="perfil_paciente.jsp">👤 Mi Perfil</a>
        <a href="clinicas_postas.jsp">🏥 Clínicas y Postas</a> 

        <div class="sidebar-est-title">Clínicas Aliadas</div>
        
        <div class="est-card-sidebar">
            <img src="img/estable1.jpg" alt="Establecimiento 1">
        </div>

        <div class="est-card-sidebar">
            <img src="img/estable2.jpg" alt="Establecimiento 2">
        </div>

        <a href="login.jsp" class="logout">Cerrar Sesión</a>
    </div>

    <div class="main-content">
        <div class="header">
            <h1>Bienvenido(a), <%= nombrePaciente %></h1>
            <p style="color: #64748b; font-weight: 600; font-size: 1.4rem;">🇵🇪 Sistema Nacional de Citas</p>
        </div>

        <div class="dashboard-grid">
            
            <!-- COLUMNA 1: Formulario para Programar Cita -->
            <div class="card">
                <h3>Agendar Nueva Cita</h3>
                <form action="ProgramarCitaServlet" method="POST">

                    <input type="hidden" name="numeroDocumento" value="<%=dniSesion%>"> 

                    <div>
                        <label for="idEstablecimiento">1. Seleccione el Establecimiento de Salud:</label>
                        <select id="idEstablecimiento" onchange="cargarEspecialidades()" required>
                            <option value="">-- Seleccione un establecimiento --</option>
                            <%
                                Connection conEst = null;
                                Statement stEst = null;
                                ResultSet rsEst = null;
                                try {
                                    conEst = Conexion.ConexionDB.conectar();
                                    stEst = conEst.createStatement();
                                    rsEst = stEst.executeQuery("SELECT id, nombre FROM establecimiento ORDER BY nombre");
                                    while(rsEst.next()) {
                            %>
                                        <option value="<%= rsEst.getInt("id") %>"><%= rsEst.getString("nombre") %></option>
                            <%
                                    }
                                } catch(Exception e) {} finally { if(rsEst!=null)rsEst.close(); if(stEst!=null)stEst.close(); if(conEst!=null)conEst.close(); }
                            %>
                        </select>

                        <label for="especialidadSelect">2. Seleccione la Especialidad Médica:</label>
                        <select id="especialidadSelect" onchange="cargarMedicos()" disabled required>
                            <option value="">-- Primero elija un establecimiento --</option>
                        </select>

                        <label for="idMedico">3. Seleccione el Médico Disponible:</label>
                        <select id="idMedico" name="idMedico" disabled required>
                            <option value="">-- Primero elija una especialidad --</option>
                        </select>

                        <label for="fecha">Fecha de la Cita:</label>
                        <input type="date" id="fecha" name="fecha" required>

                        <label for="hora">Horario Disponible:</label>
                        <select id="hora" name="hora" required>
                            <option value="">-- Seleccione la hora --</option>
                            <option value="08:00:00">08:00 AM</option>
                            <option value="10:00:00">10:00 AM</option>
                            <option value="14:00:00">02:00 PM</option>
                            <option value="16:00:00">04:30 PM</option>
                        </select>
                    </div>

                    <button type="submit">Confirmar Cita Médica</button>
                </form>
            </div>

            <!-- COLUMNA 2: Próximas Citas -->
            <div class="card" style="justify-content: flex-start;">
                <h3>Mis Citas Programadas</h3>

            <%
                Connection conCitas = null;
                PreparedStatement psCitas = null;
                ResultSet rsCitas = null;

                try {
                    conCitas = Conexion.ConexionDB.conectar();
                    // Consultas actualizadas con nombres de tablas y columnas en singular: cita, medico, establecimiento, nombre
                    String sqlCitas = "SELECT c.fecha_cita, c.hora_cita, c.estado, m.especialidad, m.nombre AS medico_nombre, e.nombre AS est_nombre " +
                                        "FROM cita c " +
                                        "INNER JOIN medico m ON c.id_medico = m.id " +
                                        "INNER JOIN establecimiento e ON m.id_establecimiento = e.id " +
                                        "WHERE c.numero_documento = ? " +
                                        "ORDER BY c.fecha_cita ASC, c.hora_cita ASC";

                    psCitas = conCitas.prepareStatement(sqlCitas);
                    psCitas.setString(1, dniSesion);
                    rsCitas = psCitas.executeQuery();

                    boolean tieneCitas = false;
                    while(rsCitas.next()) {
                        tieneCitas = true;
                        String especialidadCita = rsCitas.getString("especialidad");
                        String establecimientoCita = rsCitas.getString("est_nombre");
                        String medicoCita = rsCitas.getString("medico_nombre");
                        String fechaCita = rsCitas.getString("fecha_cita");
                        String horaCita = rsCitas.getString("hora_cita");
                        String estadoCita = rsCitas.getString("estado");

                        String colorBorde = estadoCita.equals("Atendida") ? "#10b981" : "#2563eb";
                        String estiloBadge = estadoCita.equals("Atendida") ? "background-color: #d1fae5; color: #065f46;" : "";
            %>
                        <div class="appointment-item" style="border-left-color: <%= colorBorde %>;">
                            <div class="appointment-info">
                                <h4><%= examinarTexto(especialidadCita) %></h4>
                                <p style="font-weight: 600; color: #475569;">👨‍⚕️ Dr(a). <%= examinarTexto(medicoCita) %></p>
                                <p>🏥 <%= examinarTexto(establecimientoCita) %></p>
                                <p>📅 <%= fechaCita %> - <%= horaCita.substring(0, 5) %></p>     
                            </div>
                            <span class="status-badge" style="<%= estiloBadge %>"><%= estadoCita %></span>
                        </div>
            <%
                    }

                    if (!tieneCitas) {
                        out.println("<p style='color: #64748b; text-align: center; margin-top: 30px; font-size: 1.05rem;'>Usted no cuenta con citas programadas actualmente.</p>");
                    }

                } catch(Exception e) {
                    out.println("<p style='color: red;'>Error al cargar el historial: " + e.getMessage() + "</p>");
                } finally {
                    if(rsCitas != null) rsCitas.close();
                    if(psCitas != null) psCitas.close();
                    if(conCitas != null) conCitas.close();
                }
            %>
            </div>
        </div>
    </div>

<script>
    const medicosData = [
        <%
            Connection conData = null;
            Statement stData = null;
            ResultSet rsData = null;
            try {
                conData = Conexion.ConexionDB.conectar();
                stData = conData.createStatement();
                // Consulta con tabla y columna en singular: medico, nombre
                rsData = stData.executeQuery("SELECT id, nombre, especialidad, id_establecimiento FROM medico");
                boolean primero = true;
                while(rsData.next()) {
                    if(!primero) out.print(",");
                    out.print("{id:" + rsData.getInt("id") + ", nombre:'" + rsData.getString("nombre") + "', esp:'" + rsData.getString("especialidad") + "', estId:" + rsData.getInt("id_establecimiento") + "}");
                    primero = false;
                }
            } catch(Exception e) {} finally { if(rsData!=null)rsData.close(); if(stData!=null)stData.close(); if(conData!=null)conData.close(); }
        %>
    ];

    function cargarEspecialidades() {
        const estId = document.getElementById("idEstablecimiento").value;
        const espSelect = document.getElementById("especialidadSelect");
        const medSelect = document.getElementById("idMedico");
        
        espSelect.innerHTML = '<option value="">-- Seleccione una especialidad --</option>';
        medSelect.innerHTML = '<option value="">-- Primero elija una especialidad --</option>';
        medSelect.disabled = true;

        if (!estId) {
            espSelect.disabled = true;
            return;
        }

        const especialidadesFiltradas = [...new Set(medicosData.filter(m => m.estId == estId).map(m => m.esp))];
        
        especialidadesFiltradas.forEach(esp => {
            const opt = document.createElement("option");
            opt.value = esp;
            opt.textContent = esp;
            espSelect.appendChild(opt);
        });
        
        espSelect.disabled = false;
    }

    function cargarMedicos() {
        const estId = document.getElementById("idEstablecimiento").value;
        const espNombre = document.getElementById("especialidadSelect").value;
        const medSelect = document.getElementById("idMedico");

        medSelect.innerHTML = '<option value="">-- Seleccione un médico --</option>';

        if (!espNombre) {
            medSelect.disabled = true;
            return;
        }

        const medicosFiltrados = medicosData.filter(m => m.estId == estId && m.esp === espNombre);

        medicosFiltrados.forEach(m => {
            const opt = document.createElement("option");
            opt.value = m.id;
            opt.textContent = m.nombre;
            medSelect.appendChild(opt);
        });

        medSelect.disabled = false;
    }
</script>

</body>
<%! 
    private String examinarTexto(String texto) {
        return texto != null ? texto : "";
    }
%>
</html>