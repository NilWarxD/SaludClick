<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Crear Cuenta</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }

            /* 1. CONTENEDOR PRINCIPAL: Asegura el ancho completo */
            .page-container {  
                display: flex;  
                min-height: 100vh;  
                width: 100%; 
                overflow: hidden;
                background-color: #ffffff;  
            }

            /* COLUMNA IZQUIERDA: Imagen limpia */
            .left-side {  
                width: 55%;  
                background-image: url('img/fondo2.jpg');  
                background-size: cover;  
                background-position: center center;
                background-repeat: no-repeat; 
                border-top-right-radius: 40px;
                flex-shrink: 0; 
            }

            /* COLUMNA DERECHA: Formulario */
            .right-side {  
                width: 45%;  
                height: 100%;
                display: flex;  
                justify-content: center;  
                align-items: center;  
                padding: 15px 40px;  
                background-color: #ffffff;
                flex-shrink: 0; 
            }

            /* 4. CAJA DEL FORMULARIO */
            .form-box {  
                width: 100%;  
                max-width: 480px;  
                background: transparent;  
                padding: 20px;  
                box-shadow: none; 
            }

            /* Título principal de Crear Cuenta */
            .form-box h2 { 
                color: #000000;  
                font-size: 2.5rem;  
                margin-bottom: 10px;  
                font-weight: 700;  
                text-align: center; 
            }

            /* Subtítulo */
            .form-box p { 
                text-align: center; 
                margin-bottom: 25px; 
                font-size: 1.1rem; 
                color: #475569; 
            }

            /* Etiquetas */
            label {  
                display: block;  
                font-weight: 600;  
                margin-bottom: 6px;  
                color: #475569;  
                font-size: 1.1rem; 
            }

            /* Grupo del documento */
            .document-group {  
                display: flex;  
                margin-bottom: 20px;  
                border: 1.5px solid #cbd5e1;  
                border-radius: 10px;  
                overflow: hidden;  
                width: 100%;
            }
            .document-group:focus-within { border-color: #2563eb; }

            .document-group select { 
                border: none; 
                padding: 14px 12px; 
                background: #ffffff; 
                font-size: 1.1rem; 
                color: #000000; 
                font-weight: 600; 
                outline: none; 
                border-right: 1.5px solid #cbd5e1; 
                cursor: pointer; 
            }

            .document-group input { 
                border: none; 
                width: 100%; 
                padding: 14px 15px; 
                font-size: 1.1rem; 
                outline: none; 
            }

            /* Inputs normales */
            .normal-input {  
                width: 100%;  
                padding: 14px 15px;  
                margin-bottom: 20px;  
                border: 1.5px solid #cbd5e1;  
                border-radius: 10px;  
                font-size: 1.1rem;  
                outline: none;  
            }
            .normal-input:focus { border-color: #2563eb; }

            /* Botón Registrar Paciente */
            button {  
                width: 100%;  
                background-color: #1a56db;  
                color: white;  
                padding: 14px;  
                border: none;  
                border-radius: 30px;  
                font-size: 1.4rem;  
                font-weight: bold;  
                cursor: pointer;  
                transition: background 0.2s;  
                margin-top: 10px;
            }
            button:hover { background-color: #1e429f; }

            /* Texto inferior */
            .footer-links { 
                margin-top: 25px; 
                text-align: center; 
                font-size: 1.05rem; 
                color: #475569; 
            }
            .footer-links a { color: #1a56db; text-decoration: none; font-weight: 700; }

            @media (max-width: 900px) {
                .page-container { flex-direction: column; }
                .left-side, .right-side { width: 100%; min-height: auto; }
                .left-side { height: 300px; padding: 20px; }
            }

    </style>
</head>
<body>

    <div class="page-container">
       
       <div class="left-side"></div>
        <div class="right-side">
            <div class="form-box">
                <h2>Crear Cuenta</h2>
                              
                <form action="RegistrarPacienteServlet" method="POST">
                    <label>Documento de Identidad:</label>
                    <div class="document-group">
                        <select name="tipoDocumento">
                            <option value="DNI">DNI</option>
                            <option value="CE">C.E.</option>
                            <option value="PASAPORTE">Pasaporte</option>
                        </select>
                        <input type="text" name="numeroDocumento" required placeholder="Nro de documento">
                    </div>

                    <label for="nombres">Nombres:</label>
                    <input type="text" id="nombres" name="nombres" class="normal-input" required placeholder="Nombres completos">

                    <label for="apellidos">Apellidos:</label>
                    <input type="text" id="apellidos" name="apellidos" class="normal-input" required placeholder="Apellidos completos">

                    <label for="telefono">Teléfono / Celular:</label>
                    <input type="text" id="telefono" name="telefono" class="normal-input" placeholder="Ej. 987654321">

                    <label for="email">Correo Electrónico:</label>
                    <input type="email" id="email" name="email" class="normal-input" placeholder="ejemplo@correo.com">

                    <label for="password">Crea tu Contraseña de Acceso:</label>
                    <input type="password" id="password" name="password" class="normal-input" required placeholder="Mínimo 6 caracteres">
                    
                    <button type="submit">Registrar Paciente</button>
                </form>
                
                <div class="footer-links">
                    ¿Ya tienes una cuenta? <a href="login.jsp">Iniciar Sesión</a>
                </div>
            </div>
        </div>
    </div>

</body>
</html>


