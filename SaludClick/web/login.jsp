<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Iniciar Sesión</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }
        /* CONTENEDOR PRINCIPAL */
        .page-container { 
            display: flex; 
            min-height: 100vh; 
            width: 100%; 
            overflow: hidden;
            background-color: #ffffff; 
}

        /* COLUMNA IZQUIERDA*/
         .left-side { 
            width: 55%; 
            background-image: url('img/fondo.jpg'); 
            background-size: cover; 
            background-position: center center;
            background-repeat: no-repeat; 
            border-top-right-radius: 40px;
            flex-shrink: 0; 
}

        /* COLUMNA DERECHA*/
         .right-side { 
            width: 45%; 
            height: 100%;
            display: flex; 
            justify-content: center; 
            align-items: center; 
            padding: 0 60px; 
            background-color: #ffffff;
            flex-shrink: 0; 
}
        
        /* CAJA LOGIN:*/
        .form-box { 
            width: 100%; 
            max-width: 480px; 
            background: transparent; 
            padding: 45px 40px; 
            padding: 0; 
            box-shadow: none; 
        }
        
        /* LOGO */
        .logo-container { 
            text-align: center; 
            margin-top: 50px;
            margin-bottom: 20px; 
        }
        .logo-container img { 
            width: 350px; 
            height: auto; 
            object-fit: contain;
        }
        
        /* TAMAÑO DE TEXTOS INTERNOS */
        .form-box h2 { 
            color: #000000; 
            font-size: 3rem; 
            margin-bottom: 30px; 
            font-weight: 700; 
            text-align: center; 
        }
        /*LABELS E INPUTS */
        label { 
            display: block; 
            font-weight: 600; 
            margin-bottom: 8px; 
            color: #475569; 
            font-size: 1.5rem; 
        }
        
        /* Campos de texto*/
        .document-group { 
            display: flex; 
            margin-bottom: 25px; 
            border: 1.5px solid #cbd5e1; 
            border-radius: 10px; 
            overflow: hidden; 
        }
        .document-group:focus-within { border-color: #2563eb; }

        /* Selector e input */
        .document-group select { border: none; padding: 18px 15px; background: #ffffff; font-size: 1.3rem; color: #000000; font-weight: 600; outline: none; border-right: 1.5px solid #cbd5e1; cursor: pointer; }
        .document-group input { border: none; width: 100%; padding: 18px 20px; font-size: 1.15rem; outline: none; }

        .normal-input { 
            width: 100%; 
            padding: 18px 20px; 
            margin-bottom: 35px; 
            border: 1.5px solid #cbd5e1; 
            border-radius: 10px; 
            font-size: 1.15rem; 
            outline: none; 
        }
        .normal-input:focus { border-color: #2563eb; }

        /* BOTÓN INGRESAR*/
        button { 
            width: 100%; 
            background-color: #1a56db; 
            color: white; 
            padding: 12px; 
            border: none; 
            border-radius: 30px; 
            font-size: 2.2rem; 
            font-weight: bold; 
            cursor: pointer; 
            transition: background 0.2s; 
        }
        button:hover { background-color: #1e429f; }

        .footer-links { margin-top: 35px; text-align: center; font-size: 1.05rem; color: #475569; }
        .footer-links a { color: #1a56db; text-decoration: none; font-weight: 700; }
       
        /*mansaje de error */   
    .mensaje-error {
            background: #fef2f2;
            color: #b91c1c;
            border: 1px solid #fecaca;
            border-radius: 10px;
            padding: 14px 18px;
            margin-bottom: 25px;
            font-size: 1.1rem;
            font-weight: 600;
            text-align: center;
        }
        @media (max-width: 900px) {
            .page-container { flex-direction: column; }
            .left-side, .right-side { width: 100%; min-height: auto; }
            .left-side { height: 300px; padding: 20px; }
        }
    </style>
</head>
<body>

    <div class="page-container">
        
        <!-- COLUMNA IZQUIERDA -->
        <div class="left-side"></div>
        
        <!-- COLUMNA DERECHA -->
        <div class="right-side">
            <div class="form-box">
                
                <!-- logo de SaludClick  -->
                <div class="logo-container">
                    <img src="img/logo1.png" alt="Logo SaludClick">
                </div>
                
                <h2>Iniciar sesión</h2>
                <!--mensaje de error-->
                            <% String error = request.getParameter("error"); %>
                            <% if ("1".equals(error)) { %>
                                <div class="mensaje-error">Documento o contraseña incorrectos.</div>
                            <% } else if ("2".equals(error)) { %>
                                <div class="mensaje-error">Ocurrió un problema. Inténtalo de nuevo en unos minutos.</div>
                            <% } %>

                            <form action="LoginServlet" method="POST">    
                <form action="LoginServlet" method="POST">
                    <label>Documento de Identidad:</label>
                    <div class="document-group">
                        <select name="tipoDocumento">
                            <option value="DNI">DNI</option>
                            <option value="CE">C.E.</option>
                            <option value="PASAPORTE">Pasaporte</option>
                        </select>
                        <input type="text" name="numeroDocumento" required placeholder="Nro de documento">
                    </div>

                    <label for="password">Contraseña:</label>
                    <input type="password" id="password" name="password" class="normal-input" required placeholder="Contraseña">

                    <button type="submit">Ingresar</button>
                </form>
                
                <div class="footer-links">
                    ¿No tienes cuenta? <a href="registro_paciente.jsp">Crear cuenta</a>
                </div>
            </div>
        </div>
        
    </div>

</body>

</html>
