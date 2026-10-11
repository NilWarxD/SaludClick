-- ============================================================
-- SaludClick - Script 01: roles y datos ampliados del médico
-- EJECUTAR UNA SOLA VEZ en cada computadora.
-- Si sale "Duplicate column name", significa que ya se ejecutó.
-- ============================================================

USE saludclick_db;

-- 1. Tabla de administradores -------------------------------
CREATE TABLE IF NOT EXISTS administrador (
  usuario  VARCHAR(30)  NOT NULL,
  password VARCHAR(100) NOT NULL,
  nombre   VARCHAR(100) NOT NULL,
  PRIMARY KEY (usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT IGNORE INTO administrador (usuario, password, nombre)
VALUES ('admin', 'admin123', 'Administrador');

-- 2. Datos nuevos del médico --------------------------------
ALTER TABLE medico
  ADD COLUMN tipo_documento   VARCHAR(20)  NOT NULL DEFAULT 'DNI' AFTER id,
  ADD COLUMN numero_documento VARCHAR(30)  NULL AFTER tipo_documento,
  ADD COLUMN email            VARCHAR(100) NULL,
  ADD COLUMN telefono         VARCHAR(20)  NULL,
  ADD COLUMN password         VARCHAR(100) NOT NULL DEFAULT 'medico123';

-- 3. Datos de prueba para los médicos que ya existen --------
--    DNI de prueba: 70000001, 70000002, ... (según el id)
--    Contraseña de prueba de todos: medico123
--    (se desactiva el modo seguro de Workbench solo durante este UPDATE)
SET SQL_SAFE_UPDATES = 0;

UPDATE medico
SET numero_documento = CONCAT('7000', LPAD(id, 4, '0')),
    email            = CONCAT('medico', id, '@saludclick.test')
WHERE numero_documento IS NULL;

SET SQL_SAFE_UPDATES = 1;

-- 4. Ahora que todos tienen DNI, se vuelve obligatorio y único
ALTER TABLE medico
  MODIFY numero_documento VARCHAR(30) NOT NULL,
  ADD UNIQUE KEY uq_medico_documento (numero_documento);

-- 5. Quitar la contraseña por defecto (cada médico nuevo debe
--    traer la suya desde el formulario)
ALTER TABLE medico ALTER COLUMN password DROP DEFAULT;

-- 6. Verificación
SELECT id, tipo_documento, numero_documento, nombre, especialidad, id_establecimiento
FROM medico ORDER BY id;

SELECT * FROM medico ORDER BY id DESC;