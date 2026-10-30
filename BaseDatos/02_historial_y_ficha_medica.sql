USE saludclick_db;
select * from historial_clinico;


-- 1. Agregar campos de información médica al paciente
-- Ejecutar una sola vez, después de SaludClick.sql y 01_roles_y_medico.sql.
ALTER TABLE paciente
    ADD COLUMN fecha_nacimiento DATE NULL,
    ADD COLUMN direccion VARCHAR(180) NULL,
    ADD COLUMN grupo_sanguineo VARCHAR(10) NULL,
    ADD COLUMN alergias TEXT NULL,
    ADD COLUMN antecedentes_medicos TEXT NULL,
    ADD COLUMN enfermedades_cronicas TEXT NULL,
    ADD COLUMN contacto_emergencia VARCHAR(100) NULL,
    ADD COLUMN telefono_emergencia VARCHAR(20) NULL;

-- 2. Crear la tabla del historial clínico
CREATE TABLE IF NOT EXISTS historial_clinico (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    numero_documento VARCHAR(30)
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_general_ci NOT NULL,
    id_medico INT NOT NULL,
    fecha_consulta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo_consulta VARCHAR(255),
    diagnostico TEXT,
    tratamiento TEXT,
    medicamentos TEXT,
    observaciones TEXT,

    KEY idx_historial_paciente (numero_documento),
    KEY idx_historial_medico (id_medico),

    CONSTRAINT fk_historial_paciente
        FOREIGN KEY (numero_documento)
        REFERENCES paciente(numero_documento),

    CONSTRAINT fk_historial_medico
        FOREIGN KEY (id_medico)
        REFERENCES medico(id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci;

-- 3. Verificar la estructura creada
DESCRIBE paciente;
DESCRIBE historial_clinico;
