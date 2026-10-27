CREATE DATABASE  IF NOT EXISTS `saludclick_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `saludclick_db`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: saludclick_db
-- ------------------------------------------------------
-- Server version	26.7.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'fb38c56b-c380-11f1-87a8-08bfb81b3a37:1-69';

--
-- Table structure for table `administrador`
--

DROP TABLE IF EXISTS `administrador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `administrador` (
  `usuario` varchar(30) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  PRIMARY KEY (`usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administrador`
--

LOCK TABLES `administrador` WRITE;
/*!40000 ALTER TABLE `administrador` DISABLE KEYS */;
INSERT INTO `administrador` VALUES ('admin','Administrador SaludClick','admin123');
/*!40000 ALTER TABLE `administrador` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cita`
--

DROP TABLE IF EXISTS `cita`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cita` (
  `id` int NOT NULL AUTO_INCREMENT,
  `numero_documento` varchar(15) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `id_medico` int DEFAULT NULL,
  `fecha_cita` date NOT NULL,
  `hora_cita` time NOT NULL,
  `estado` varchar(30) COLLATE utf8mb4_general_ci DEFAULT 'Programada',
  PRIMARY KEY (`id`),
  KEY `numero_documento` (`numero_documento`),
  KEY `id_medico` (`id_medico`),
  CONSTRAINT `cita_ibfk_1` FOREIGN KEY (`numero_documento`) REFERENCES `paciente` (`numero_documento`),
  CONSTRAINT `cita_ibfk_2` FOREIGN KEY (`id_medico`) REFERENCES `medico` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cita`
--

LOCK TABLES `cita` WRITE;
/*!40000 ALTER TABLE `cita` DISABLE KEYS */;
INSERT INTO `cita` VALUES (1,'89898989',3,'2026-10-10','14:00:00','Programada'),(2,'89898989',10,'2026-10-12','10:00:00','Programada'),(3,'89898989',10,'2026-10-24','10:00:00','Programada');
/*!40000 ALTER TABLE `cita` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `establecimiento`
--

DROP TABLE IF EXISTS `establecimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `establecimiento` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `tipo` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `direccion` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `establecimiento`
--

LOCK TABLES `establecimiento` WRITE;
/*!40000 ALTER TABLE `establecimiento` DISABLE KEYS */;
INSERT INTO `establecimiento` VALUES (1,'Clínica Internacional','Clinica','Sede Lima'),(2,'Centro de Salud San Carlos','Posta','Santa Anita');
/*!40000 ALTER TABLE `establecimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historial_clinico`
--

DROP TABLE IF EXISTS `historial_clinico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historial_clinico` (
  `id` int NOT NULL AUTO_INCREMENT,
  `numero_documento` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `id_medico` int NOT NULL,
  `fecha_consulta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `motivo_consulta` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `diagnostico` text COLLATE utf8mb4_general_ci,
  `tratamiento` text COLLATE utf8mb4_general_ci,
  `medicamentos` text COLLATE utf8mb4_general_ci,
  `observaciones` text COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id`),
  KEY `idx_historial_paciente` (`numero_documento`),
  KEY `idx_historial_medico` (`id_medico`),
  CONSTRAINT `fk_historial_medico` FOREIGN KEY (`id_medico`) REFERENCES `medico` (`id`),
  CONSTRAINT `fk_historial_paciente` FOREIGN KEY (`numero_documento`) REFERENCES `paciente` (`numero_documento`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historial_clinico`
--

LOCK TABLES `historial_clinico` WRITE;
/*!40000 ALTER TABLE `historial_clinico` DISABLE KEYS */;
INSERT INTO `historial_clinico` VALUES (1,'89898989',10,'2026-10-23 23:46:56','Prueba funcional de SaludClick','Registro de prueba, sin diagnóstico clínico xd','No aplica; registro de prueba.','No aplica xd muy sano','Verificar que la consulta se guarde y aparezca en el perfil del paciente.'),(2,'89898989',10,'2026-10-24 06:42:53','Prueba de segunda consulta.','Registro de prueba, sin diagnóstico clínico','No aplica; prueba del sistema para confirmar el guardados pes','no aplica aun es prueba 2','Verificar que el sistema conserve las consultas anteriores');
/*!40000 ALTER TABLE `historial_clinico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medico`
--

DROP TABLE IF EXISTS `medico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medico` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo_documento` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'DNI',
  `numero_documento` varchar(30) COLLATE utf8mb4_general_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `especialidad` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `id_establecimiento` int DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_medico_documento` (`numero_documento`),
  KEY `id_establecimiento` (`id_establecimiento`),
  CONSTRAINT `medico_ibfk_1` FOREIGN KEY (`id_establecimiento`) REFERENCES `establecimiento` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medico`
--

LOCK TABLES `medico` WRITE;
/*!40000 ALTER TABLE `medico` DISABLE KEYS */;
INSERT INTO `medico` VALUES (1,'DNI','70000001','Dr. Carlos Mendoza','Medicina General',1,'medico1@saludclick.test',NULL,'medico123'),(2,'DNI','70000002','Dr. Luis Alberto','Traumatología',1,'medico2@saludclick.test',NULL,'medico123'),(3,'DNI','70000003','Dra. Elena Rostworowski','Psicología',1,'medico3@saludclick.test',NULL,'medico123'),(4,'DNI','70000004','Dr. Juan Pérez','Pediatría',1,'medico4@saludclick.test',NULL,'medico123'),(5,'DNI','70000005','Dra. Maria Sarmiento','Ginecología',1,'medico5@saludclick.test',NULL,'medico123'),(6,'DNI','70000006','Dr. Jose Quispe','Oftalmología',1,'medico6@saludclick.test',NULL,'medico123'),(7,'DNI','70000007','Dr. Humberto Barnechea','Otorrinolaringología',1,'medico7@saludclick.test',NULL,'medico123'),(8,'DNI','70000008','Dra. Rocio Martinez ','Otorrinolaringología',1,'medico8@saludclick.test',NULL,'medico123'),(9,'DNI','70000009','Dra. Sofía Benavides','Gastroenterología',1,'medico9@saludclick.test',NULL,'medico123'),(10,'DNI','70000010','Dra. Ana Espinoza','Medicina General',2,'medico10@saludclick.test',NULL,'medico123'),(11,'DNI','70000011','Dr. Ricardo Palma','Pediatría',2,'medico11@saludclick.test',NULL,'medico123'),(12,'DNI','70000012','Dra. Carmen Rosa','Odontología',2,'medico12@saludclick.test',NULL,'medico123'),(13,'DNI','70000013','Lic. María Wong','Obstetricia',2,'medico13@saludclick.test',NULL,'medico123'),(14,'DNI','70000014','Ps. Jorge Chávez','Psicología',2,'medico14@saludclick.test',NULL,'medico123');
/*!40000 ALTER TABLE `medico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paciente`
--

DROP TABLE IF EXISTS `paciente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paciente` (
  `numero_documento` varchar(30) COLLATE utf8mb4_general_ci NOT NULL,
  `tipo_documento` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `apellido` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(100) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'nil123',
  `fecha_nacimiento` date DEFAULT NULL,
  `direccion` varchar(180) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `grupo_sanguineo` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `alergias` text COLLATE utf8mb4_general_ci,
  `antecedentes_medicos` text COLLATE utf8mb4_general_ci,
  `enfermedades_cronicas` text COLLATE utf8mb4_general_ci,
  `contacto_emergencia` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `telefono_emergencia` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`numero_documento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paciente`
--

LOCK TABLES `paciente` WRITE;
/*!40000 ALTER TABLE `paciente` DISABLE KEYS */;
INSERT INTO `paciente` VALUES ('12345678','DNI','JOSUE','SILVA','994128807','xonnekpaucarsilva2@gmailcom','12345678',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('88888888','DNI','Miguel','Enriquez Galvez','999999991','migueleg@gmail.com','miguel123',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('89898989','DNI','Nilton','Guerra Villegas','999999999','niltongv@gmail.com','nilton123',NULL,'Dirección de prueba',NULL,'Pendiente de confirmación (prueba)','Registro de prueba, sin datos clínicos reales.','Pendiente de confirmación (prueba).','Contacto de prueba','123456788');
/*!40000 ALTER TABLE `paciente` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-24  7:06:45
