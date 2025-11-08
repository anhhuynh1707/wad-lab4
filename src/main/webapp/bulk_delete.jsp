<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    String[] selectedIds = request.getParameterValues("selectedIds");

    if (selectedIds == null || selectedIds.length == 0) {
        response.sendRedirect("list_students.jsp?error=No students selected for deletion");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "123456"
        );

        String sql = "DELETE FROM students WHERE id = ?";
        pstmt = conn.prepareStatement(sql);

        for (String id : selectedIds) {
            pstmt.setInt(1, Integer.parseInt(id));
            pstmt.addBatch();
        }

        int[] result = pstmt.executeBatch();

        response.sendRedirect("list_students.jsp?message=" + result.length + " students deleted successfully");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("list_students.jsp?error=Failed to delete selected students");
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>