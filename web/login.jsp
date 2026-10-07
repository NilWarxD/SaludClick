<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SaludClick - Iniciar Sesión</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, sans-serif; }
        /* 1. CONTENEDOR PRINCIPAL: Asegura el ancho completo */
        .page-container { 
            display: flex; 
            min-height: 100vh; 
            width: 100%; /* Asegura que ocupe toda la pantalla */
            overflow: hidden;
            background-color: #ffffff; 
}

        /* COLUMNA IZQUIERDA: Imagen limpia  */
         .left-side { 
            width: 55%; 
            background-image: url('img/fondo.jpg'); 
            background-size: cover; 
            background-position: center center;
            background-repeat: no-repeat; /* Evita que la foto se duplique */
            border-top-right-radius: 40px;
            flex-shrink: 0; /* OBLIGATORIO: Evita que el navegador encoja o corte esta columna */
}

        /* COLUMNA DERECHA: Formulario  */
         .right-side { 
            width: 45%; 
            height: 100%;
            display: flex; 
            justify-content: center; 
            align-items: center; 
            padding: 0 60px; 
            background-color: #ffffff;
            flex-shrink: 0; /* OBLIGATORIO: Evita que se encoja el lado del formulario */
}
        
        /* 4. CAJA BLANCA DEL LOGIN:*/
        .form-box { 
            width: 100%; 
            max-width: 480px; 
            background: transparent; 
            padding: 45px 40px; 
            padding: 0; 
            box-shadow: none; 
        }
        
        /* CONTENEDOR DEL LOGO AGRANDADO */
        .logo-container { 
            text-align: center; 
            margin-top: 50px;
            margin-bottom: 20px; 
        }
        .logo-container img { 
            width: 350px; /* <--- Agrandamos considerablemente tu logo de SaludClick */
            height: auto; 
            object-fit: contain;
        }
        
        /* 5. TAMAÑO DE LOS TEXTOS INTERNOS: iniciar sesion */
        .form-box h2 { 
            color: #000000; 
            font-size: 3rem; 
            margin-bottom: 30px; 
            font-weight: 700; 
            text-align: center; 
        }
        /* 6. LABELS E INPUTS GIGANTES: letra documento y contra */
        label { 
            display: block; 
            font-weight: 600; 
            margin-bottom: 8px; 
            color: #475569; 
            font-size: 1.5rem; 
        }
        
        /* Campos de texto más grandes y cómodos para el usuario */
        .document-group { 
            display: flex; 
            margin-bottom: 25px; 
            border: 1.5px solid #cbd5e1; 
            border-radius: 10px; 
            overflow: hidden; 
        }
        .document-group:focus-within { border-color: #2563eb; }

        /* Selector e input más altos y espaciosos */
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

        /* 7. BOTÓN INGRESAR ROBUSTO Y REDONDEADO */
        button { 
            width: 100%; 
            background-color: #1a56db; 
            color: white; 
            padding: 12px; 
            border: none; 
            border-radius: 30px; /* <--- Botón en forma de óvalo idéntico al de la clínica */
            font-size: 2.2rem; 
            font-weight: bold; 
            cursor: pointer; 
            transition: background 0.2s; 
        }
        button:hover { background-color: #1e429f; }

        .footer-links { margin-top: 35px; text-align: center; font-size: 1.05rem; color: #475569; }
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
        
        <!-- COLUMNA IZQUIERDA: Aquí va tu imagen familiar limpia (45% del ancho) -->
        <div class="left-side"></div>
        
        <!-- COLUMNA DERECHA: Aquí va tu caja de login ampliada (55% del ancho) -->
        <div class="right-side">
            <div class="form-box">
                
                <!-- Tu logotipo de SaludClick en tamaño grande -->
                <div class="logo-container">
                    <img src="img/logo1.png" alt="Logo SaludClick">
                </div>
                
                <h2>Iniciar sesión</h2>
                                
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
