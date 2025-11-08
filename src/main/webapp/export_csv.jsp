<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/csv");
    response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

    // Connect to database
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "123456"
        );

        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT id, student_code, full_name, email, major FROM students ORDER BY id ASC");

        // Print CSV header row
        out.println("ID,Student Code,Full Name,Email,Major");

        // Loop through records and print CSV data
        while (rs.next()) {
            int id = rs.getInt("id");
            String code = rs.getString("student_code");
            String name = rs.getString("full_name");
            String email = rs.getString("email");
            String major = rs.getString("major");

            // Handle null values safely
            if (email == null) email = "";
            if (major == null) major = "";

            out.println(id + "," +
                        "\"" + code + "\"," +
                        "\"" + name.replace("\"", "\"\"") + "\"," +
                        "\"" + email.replace("\"", "\"\"") + "\"," +
                        "\"" + major.replace("\"", "\"\"") + "\"");
        }

    } catch (Exception e) {
        out.println("Error generating CSV: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>