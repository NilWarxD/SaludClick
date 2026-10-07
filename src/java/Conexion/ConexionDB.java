package Conexion;
import java.sql.*;
public class ConexionDB {
 private static final String URL="jdbc:mysql://localhost:3306/SaludClick_db?useSSL=false&serverTimezone=UTC";
 private static final String DRIVER="com.mysql.cj.jdbc.Driver";
 private static final String USUARIO="root";
 private static final String CLAVE="";
    
    public static Connection conectar() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USUARIO, CLAVE);
            System.out.println("¡Conexión exitosa a SaludClick!");
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error de conexión: " + e.getMessage());
        }
        return con;
    }
}
