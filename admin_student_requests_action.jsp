<%@ page language="java" import="java.sql.*"%>
<%@ include file="db.jspf" %>
<%
    // Ensure only logged in admin can take action
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    String c[] = request.getParameterValues("ad");

    if (c != null && c.length > 0) {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            con = getDBConnection();

            if (request.getParameter("reject") != null) {
                pstmt = con.prepareStatement("delete from student where roll_no = ?");
                for (String s : c) {
                    try {
                        pstmt.setString(1, s.trim());
                        pstmt.executeUpdate();
                    } catch (Exception ex) {}
                }
            } else if (request.getParameter("accept") != null) {
                pstmt = con.prepareStatement("update student set is_approved = 1 where roll_no = ?");
                for (String s : c) {
                    try {
                        pstmt.setString(1, s.trim());
                        pstmt.executeUpdate();
                    } catch (Exception ex) {}
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception ignored) {}
            if (con != null) try { con.close(); } catch(Exception ignored) {}
        }
    }
    response.sendRedirect("admin_student_requests.jsp");
%>