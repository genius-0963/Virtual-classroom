<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.sql.*, java.util.*"%>
<%@ include file="db.jspf" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }

    String actionMsg = null;
    String errorMsg = null;

    // Handle student deletion
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("delete_student") != null) {
        String roll = request.getParameter("student_roll");
        if (roll != null) {
            try (Connection con = getDBConnection();
                 PreparedStatement ps = con.prepareStatement("DELETE FROM student WHERE roll_no = ?")) {
                ps.setString(1, roll.trim());
                ps.executeUpdate();
                actionMsg = "Student (Roll No: " + escapeHtml(roll) + ") removed successfully.";
            } catch (Exception e) {
                errorMsg = "Error deleting student: " + e.getMessage();
            }
        }
    }

    // Handle faculty deletion
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("delete_faculty") != null) {
        String sub = request.getParameter("faculty_subject");
        if (sub != null) {
            try (Connection con = getDBConnection();
                 PreparedStatement ps = con.prepareStatement("DELETE FROM faculty WHERE subject = ?")) {
                ps.setString(1, sub.trim());
                ps.executeUpdate();
                actionMsg = "Faculty (Subject: " + sub + ") removed successfully.";
            } catch (Exception e) {
                errorMsg = "Error deleting faculty: " + e.getMessage();
            }
        }
    }
%>
<!doctype html>
<html class="no-js" lang="zxx">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Manage Users - Admin</title>
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="manifest" href="site.webmanifest">
    <link rel="shortcut icon" type="image/x-icon" href="assets/img/favicon.ico">

    <!-- CSS here -->
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/owl.carousel.min.css">
    <link rel="stylesheet" href="assets/css/slicknav.css">
    <link rel="stylesheet" href="assets/css/flaticon.css">
    <link rel="stylesheet" href="assets/css/progressbar_barfiller.css">
    <link rel="stylesheet" href="assets/css/gijgo.css">
    <link rel="stylesheet" href="assets/css/animate.min.css">
    <link rel="stylesheet" href="assets/css/animated-headline.css">
    <link rel="stylesheet" href="assets/css/magnific-popup.css">
    <link rel="stylesheet" href="assets/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/css/themify-icons.css">
    <link rel="stylesheet" href="assets/css/slick.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>

<body>
    <!-- Preloader Start -->
    <div id="preloader-active">
        <div class="preloader d-flex align-items-center justify-content-center">
            <div class="preloader-inner position-relative">
                <div class="preloader-circle"></div>
                <div class="preloader-img pere-text">
                    <img src="assets/img/logo/loder.png" alt="">
                </div>
            </div>
        </div>
    </div>
    <!-- Preloader End -->

    <header>
        <div class="header-area header-transparent">
            <div class="main-header ">
                <div class="header-bottom header-sticky">
                    <div class="container-fluid">
                        <div class="row align-items-center">
                            <div class="col-xl-2 col-lg-2">
                                <div class="logo">
                                    <a href="admin_dashboard.jsp"><img src="assets/img/logo/logo.png" alt=""></a>
                                </div>
                            </div>
                            <div class="col-xl-10 col-lg-10">
                                <div class="menu-wrapper d-flex align-items-center justify-content-end">
                                    <div class="main-menu d-none d-lg-block">
                                        <nav>
                                            <ul id="navigation">
                                                <li><a href="admin_dashboard.jsp">Home</a></li>
                                                <li class="active"><a href="admin_users.jsp">Manage Users</a></li>
                                                <li><a href="admin_student_requests.jsp">Student Requests</a></li>
                                                <li><a href="admin_faculty_requests.jsp">Faculty Requests</a></li>
                                                <li class="button-header"><a href="admin_logout.jsp" class="btn btn3">Log Out</a></li>
                                            </ul>
                                        </nav>
                                    </div>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="mobile_menu d-block d-lg-none"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <main>
        <section class="slider-area ">
            <div class="slider-active">
                <div class="single-slider slider-height d-flex align-items-center">
                    <div class="container">
                        <div class="row">
                            <div class="col-xl-7 col-lg-8 col-md-12">
                                <div class="hero__caption">
                                    <h1 data-animation="fadeInLeft" data-delay="0.2s">Manage Enrolled Users</h1>
                                    <p data-animation="fadeInLeft" data-delay="0.4s">View and manage active students and faculty accounts.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <div class="container py-5">
            <% if (actionMsg != null) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <%= escapeHtml(actionMsg) %>
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            <% } %>
            <% if (errorMsg != null) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <%= escapeHtml(errorMsg) %>
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            <% } %>

            <!-- Active Students -->
            <div class="card mb-5 shadow-sm border-0">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 text-white"><i class="fas fa-user-graduate mr-2"></i> Active Enrolled Students</h5>
                    <a href="admin_student_requests.jsp" class="btn btn-sm btn-light">Pending Requests</a>
                </div>
                <div class="card-body p-0 table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>Roll No</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Degree & Course</th>
                                <th>Year</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection con = getDBConnection();
                                 Statement st = con.createStatement();
                                 ResultSet rs = st.executeQuery("SELECT roll_no, name, email_id, degree, course, year FROM student WHERE is_approved = 1 ORDER BY roll_no ASC")) {
                                boolean hasStudents = false;
                                while (rs.next()) {
                                    hasStudents = true;
                                    String roll = rs.getString("roll_no");
                            %>
                                <tr>
                                    <td><strong><%= escapeHtml(roll) %></strong></td>
                                    <td><%= escapeHtml(rs.getString("name")) %></td>
                                    <td><%= escapeHtml(rs.getString("email_id")) %></td>
                                    <td><%= escapeHtml(rs.getString("degree")) %> - <%= escapeHtml(rs.getString("course")) %></td>
                                    <td>Year <%= rs.getInt("year") %></td>
                                    <td>
                                        <form action="admin_users.jsp" method="POST" onsubmit="return confirm('Remove student with Roll No <%= escapeHtml(roll) %>?');">
                                             <input type="hidden" name="student_roll" value="<%= escapeHtml(roll) %>">
                                            <button type="submit" name="delete_student" value="1" class="btn btn-sm btn-outline-danger">
                                                <i class="fas fa-trash-alt"></i> Remove
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <%
                                }
                                if (!hasStudents) {
                            %>
                                <tr><td colspan="6" class="text-center py-4 text-muted">No approved students found.</td></tr>
                            <%
                                }
                            } catch (Exception e) {
                            %>
                                <tr><td colspan="6" class="text-danger">Error: <%= escapeHtml(e.getMessage()) %></td></tr>
                            <%
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Active Faculty -->
            <div class="card shadow-sm border-0">
                <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 text-white"><i class="fas fa-chalkboard-teacher mr-2"></i> Active Registered Faculty</h5>
                    <a href="admin_faculty_requests.jsp" class="btn btn-sm btn-light">Pending Requests</a>
                </div>
                <div class="card-body p-0 table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>Name</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Subject</th>
                                <th>Degree & Course</th>
                                <th>Year</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection con = getDBConnection();
                                 Statement st = con.createStatement();
                                 ResultSet rs = st.executeQuery("SELECT name, username, email_id, subject, degree, course, year FROM faculty WHERE is_approved = 1 ORDER BY name ASC")) {
                                boolean hasFaculty = false;
                                while (rs.next()) {
                                    hasFaculty = true;
                                    String sub = rs.getString("subject");
                            %>
                                <tr>
                                    <td><strong><%= escapeHtml(rs.getString("name")) %></strong></td>
                                    <td><%= escapeHtml(rs.getString("username")) %></td>
                                    <td><%= escapeHtml(rs.getString("email_id")) %></td>
                                    <td><span class="badge badge-info"><%= escapeHtml(sub) %></span></td>
                                    <td><%= escapeHtml(rs.getString("degree")) %> - <%= escapeHtml(rs.getString("course")) %></td>
                                    <td>Year <%= rs.getInt("year") %></td>
                                    <td>
                                        <form action="admin_users.jsp" method="POST" onsubmit="return confirm('Remove faculty for <%= escapeHtml(sub) %>?');">
                                            <input type="hidden" name="faculty_subject" value="<%= escapeHtml(sub) %>">
                                            <button type="submit" name="delete_faculty" value="1" class="btn btn-sm btn-outline-danger">
                                                <i class="fas fa-trash-alt"></i> Remove
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <%
                                }
                                if (!hasFaculty) {
                            %>
                                <tr><td colspan="7" class="text-center py-4 text-muted">No approved faculty found.</td></tr>
                            <%
                                }
                            } catch (Exception e) {
                            %>
                                <tr><td colspan="7" class="text-danger">Error: <%= escapeHtml(e.getMessage()) %></td></tr>
                            <%
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <div class="footer-wrappper footer-bg">
            <div class="footer-area footer-padding">
                <div class="container">
                    <div class="row justify-content-between">
                        <div class="col-xl-4 col-lg-5 col-md-4 col-sm-6">
                            <div class="single-footer-caption mb-50">
                                <div class="footer-logo mb-25">
                                    <a href="index.jsp"><img src="assets/img/logo/logo2_footer.png" alt=""></a>
                                </div>
                                <div class="footer-tittle">
                                    <div class="footer-pera">
                                        <p>Virtual Classroom learning portal.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <script src="./assets/js/vendor/modernizr-3.5.0.min.js"></script>
    <script src="./assets/js/vendor/jquery-1.12.4.min.js"></script>
    <script src="./assets/js/popper.min.js"></script>
    <script src="./assets/js/bootstrap.min.js"></script>
    <script src="./assets/js/plugins.js"></script>
    <script src="./assets/js/main.js"></script>
</body>
</html>
