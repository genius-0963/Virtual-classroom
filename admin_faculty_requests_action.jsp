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
                pstmt = con.prepareStatement("delete from faculty where subject = ?");
                for (String s : c) {
                    if (s != null && !s.trim().isEmpty()) {
                        pstmt.setString(1, s.trim());
                        pstmt.executeUpdate();
                    }
                }
            } else if (request.getParameter("accept") != null) {
                pstmt = con.prepareStatement("update faculty set is_approved = 1 where subject = ?");
                for (String s : c) {
                    if (s != null && !s.trim().isEmpty()) {
                        pstmt.setString(1, s.trim());
                        pstmt.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception ignored) {}
            if (con != null) try { con.close(); } catch(Exception ignored) {}
        }
    }
    response.sendRedirect("admin_faculty_requests.jsp");
%>