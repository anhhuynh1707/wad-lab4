<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
            user-select: none;
        }
        th a {
		    color: white;
		    text-decoration: none;
		    font-weight: 600;
		}
		
		th a:hover {
		    color: #ffe082; /* soft gold hover effect */
		    text-decoration: none;
		}
		th:hover {
		    background-color: #0056b3;
		    cursor: pointer;
		}
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }
        .pagination {
            margin-top: 20px;
            text-align: center;
        }
        .pagination a, .pagination strong {
            margin: 0 5px;
            padding: 6px 12px;
            border: 1px solid #007bff;
            border-radius: 4px;
            text-decoration: none;
            color: #007bff;
        }
        .pagination strong {
            background-color: #007bff;
            color: white;
        }
        .message {
		    display: flex;
		    align-items: center;
		    gap: 8px;
		    padding: 10px;
		    margin-bottom: 20px;
		    border-radius: 5px;
		    font-weight: bold;
		    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
		}
		.message.success {
		    background-color: #d4edda;
		    color: #155724;
		    border-left: 5px solid #28a745;
		}
		.message.error {
		    background-color: #f8d7da;
		    color: #721c24;
		    border-left: 5px solid #dc3545;
		}
		.message i {
		    font-size: 18px;
		}
		/* Table scrollable on small screens and better mobile layout */
		.table-responsive {
		    overflow-x: auto;
		}
		@media (max-width: 768px) {
		    table {
		        font-size: 12px;
		    }
		    th, td {
		        padding: 5px;
		    }
		}
		.delete-btn {
		    background-color: #dc3545;
		    color: white;
		    border: none;
		    padding: 10px 18px;
		    border-radius: 6px;
		    cursor: pointer;
		    font-weight: 500;
		    transition: all 0.2s ease;
		}
		.delete-btn:hover {
		    background-color: #bb2d3b;
		    transform: scale(1.05);
		}
    </style>
</head>
<body>
    <h1>📚 Student Management System</h1>
    
    <% if (request.getParameter("message") != null) { %>
        <div class="message success">
            <i>✅</i> <%= request.getParameter("message") %>
        </div>
    <% } %>
    
    <% if (request.getParameter("error") != null) { %>
        <div class="message error">
            <i>❌</i> <%= request.getParameter("error") %>
        </div>
    <% } %>
    
    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
    <a href="export_csv.jsp" class="btn">⬇️ Export to CSV</a>
    
    <!--  Create Search Form -->
    
    <form action="list_students.jsp" method="GET">
    <input type="text" name="keyword" placeholder="Search by name or code...">
    <button type="submit">Search</button>
    <a href="list_students.jsp">Clear</a>
	</form>
	<br>
	
	<script>
	<!-- Success/Error Message Styling --> 
	setTimeout(function() {
	    var messages = document.querySelectorAll('.message');
	    messages.forEach(function(msg) {
	        msg.style.transition = "opacity 0.5s ease";
	        msg.style.opacity = '0';
	        setTimeout(() => msg.style.display = 'none', 500);
	    });
	}, 3000); // Auto-hide after 3 seconds
	//Select all and confirmation
	function toggleSelectAll(source) {
	    const checkboxes = document.querySelectorAll('input[name="selectedIds"]');
	    checkboxes.forEach(cb => cb.checked = source.checked);
	}

	function confirmBulkDelete() {
	    const selected = document.querySelectorAll('input[name="selectedIds"]:checked');
	    if (selected.length === 0) {
	        alert("Please select at least one student to delete.");
	        return false;
	    }
	    return confirm("Are you sure you want to delete the selected students?");
	}
	</script>
<%
    //Pagination & search setup
    int currentPage = 1;
    int totalPages = 1;
    int totalRecords = 0;
    int recordsPerPage = 10;
    String keyword = request.getParameter("keyword");
    String queryString = "";

    String pageParam = request.getParameter("page");
    try {
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        }
    } catch (NumberFormatException e) {
        currentPage = 1;
    }

    if (keyword != null && !keyword.trim().isEmpty()) {
        queryString = "&keyword=" + keyword;
    }

    int offset = (currentPage - 1) * recordsPerPage;
 	// Sorting setup
    String sortBy = request.getParameter("sort");
    String order = request.getParameter("order");

    if (sortBy == null || sortBy.trim().isEmpty()) sortBy = "id";
    if (order == null || order.trim().isEmpty()) order = "desc";

    String nextOrder = order.equals("asc") ? "desc" : "asc";
%>
    <form action="bulk_delete.jsp" method="POST" onsubmit="return confirmBulkDelete();">
    <div class="table-responsive">
    <table>
        <thead>
            <tr>
                <th><input type="checkbox" id="selectAll" onclick="toggleSelectAll(this)"></th>
                <th>ID</th>
                <th>Student Code</th>
                <th>
				    <a href="list_students.jsp?sort=full_name&order=<%= nextOrder %><%= queryString %>">Full Name</a>
				    <% if ("full_name".equals(sortBy)) { %>
				        <%= order.equals("asc") ? "▲" : "▼" %>
				    <% } %>
				</th>
                <th>Email</th>
                <th>Major</th>
                <th>
	                <a href="list_students.jsp?sort=created_at&order=<%= nextOrder %><%= queryString %>">Created At</a>
	                <% if ("created_at".equals(sortBy)) { %>
	                    <%= order.equals("asc") ? "▲" : "▼" %>
	                <% } %>
            	</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	PreparedStatement countStmt = null;
	ResultSet rs = null;
	ResultSet countRs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "123456"
        );
        String sql;
        //Count total recors
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql = "SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ?";
            countStmt = conn.prepareStatement(sql);
            countStmt.setString(1, "%" + keyword + "%");
            countStmt.setString(2, "%" + keyword + "%");
            countStmt.setString(3, "%" + keyword + "%");
        } else {
            countStmt = conn.prepareStatement("SELECT COUNT(*) FROM students");
        }

        countRs = countStmt.executeQuery();
        if (countRs.next()) totalRecords = countRs.getInt(1);
        totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
        
        //Get students
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ? " +
                  "ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            pstmt.setString(3, "%" + keyword + "%");
            pstmt.setInt(4, recordsPerPage);
            pstmt.setInt(5, offset);
        } else {
            sql = "SELECT * FROM students ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, recordsPerPage);
            pstmt.setInt(2, offset);
        }

        rs = pstmt.executeQuery();
        boolean hasResult = false;
        while (rs.next()) {
            hasResult = true;
        	int id = rs.getInt("id");
            String studentCode = rs.getString("student_code");
            String fullName = rs.getString("full_name");
            String email = rs.getString("email");
            String major = rs.getString("major");
            Timestamp createdAt = rs.getTimestamp("created_at");
%>
            <tr>
                <td><input type="checkbox" name="selectedIds" value="<%= id %>"></td>
                <td><%= id %></td>
                <td><%= studentCode %></td>
                <td><%= fullName %></td>
                <td><%= email != null ? email : "N/A" %></td>
                <td><%= major != null ? major : "N/A" %></td>
                <td><%= createdAt %></td>
                <td>
                    <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
                    <a href="delete_student.jsp?id=<%= id %>" 
                       class="action-link delete-link"
                       onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                </td>
            </tr>
<%
        }
        if (!hasResult) {
        	%>
        	    <tr><td colspan="7" style="text-align:center;">No students found.</td></tr>
        	<%
        }
    } catch (ClassNotFoundException e) {
        out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
        e.printStackTrace();
    } catch (SQLException e) {
        out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        try {
        	if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (countRs != null) countRs.close();
            if (countStmt != null) countStmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
        </tbody>
    </table>
    </div>
    <!-- Delete Selected Button -->
    <br>
	<button type="submit" class="btn delete-btn">🗑️ Delete Selected</button>
	</form>
    <!-- Pagination -->
    <div class="pagination">
	    <% if (currentPage > 1) { %>
	        <a href="list_students.jsp?page=<%= currentPage - 1 %>&sort=<%= sortBy %>&order=<%= order %><%= queryString %>">Previous</a>
	    <% } %>
	
	    <% for (int i = 1; i <= totalPages; i++) { %>
	        <% if (i == currentPage) { %>
	            <strong><%= i %></strong>
	        <% } else { %>
	            <a href="list_students.jsp?page=<%= i %>&sort=<%= sortBy %>&order=<%= order %><%= queryString %>"><%= i %></a>
	        <% } %>
	    <% } %>
	
	    <% if (currentPage < totalPages) { %>
	        <a href="list_students.jsp?page=<%= currentPage + 1 %>&sort=<%= sortBy %>&order=<%= order %><%= queryString %>">Next</a>
	    <% } %>
	</div>
</body>
</html>