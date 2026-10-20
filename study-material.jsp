<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.sql.*, java.util.*"%>
<%@ include file="db.jspf" %>
<%
    String userName = (String)session.getAttribute("student");
    String userRole = "student";
    String logoutUrl = "student_logout.jsp";
    String homeUrl = "student_dashboard.jsp";

    if (userName == null) {
        userName = (String)session.getAttribute("faculty");
        userRole = "faculty";
        logoutUrl = "faculty_logout.jsp";
        homeUrl = "faculty_dashboard.jsp";
    }
    if (userName == null) {
        userName = (String)session.getAttribute("admin");
        userRole = "admin";
        logoutUrl = "admin_logout.jsp";
        homeUrl = "admin_dashboard.jsp";
    }
    if (userName == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String actionMsg = null;
    String errorMsg = null;

    // Handle upload / add study material by faculty or admin
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("submit_material") != null) {
        if (!"student".equals(userRole)) {
            String title = request.getParameter("title");
            String subject = request.getParameter("subject");
            String degree = request.getParameter("degree");
            String description = request.getParameter("description");
            String resourceUrl = request.getParameter("resource_url");

            if (title != null && subject != null && resourceUrl != null && !title.trim().isEmpty() && !resourceUrl.trim().isEmpty()) {
                try (Connection con = getDBConnection();
                     PreparedStatement ps = con.prepareStatement("INSERT INTO study_materials (title, subject, degree, description, resource_url, uploaded_by) VALUES (?, ?, ?, ?, ?, ?)")) {
                    ps.setString(1, title.trim());
                    ps.setString(2, subject.trim());
                    ps.setString(3, degree != null ? degree.trim() : "All");
                    ps.setString(4, description != null ? description.trim() : "");
                    ps.setString(5, resourceUrl.trim());
                    ps.setString(6, userName);
                    ps.executeUpdate();
                    actionMsg = "Study material published successfully!";
                } catch (Exception e) {
                    errorMsg = "Failed to add study material: " + e.getMessage();
                }
            } else {
                errorMsg = "Please fill in title, subject, and resource URL.";
            }
        }
    }
%>
<!doctype html>
<html class="no-js" lang="zxx">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Study Materials - Virtual Classroom</title>
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

    <style>
        .material-card {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
            transition: transform 0.2s;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .material-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 18px rgba(0,0,0,0.1);
        }
    </style>
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
                                    <a href="<%= homeUrl %>"><img src="assets/img/logo/logo.png" alt=""></a>
                                </div>
                            </div>
                            <div class="col-xl-10 col-lg-10">
                                <div class="menu-wrapper d-flex align-items-center justify-content-end">
                                    <div class="main-menu d-none d-lg-block">
                                        <nav>
                                            <ul id="navigation">
                                                <li><a href="<%= homeUrl %>">Home</a></li>
                                                <li class="active"><a href="study-material.jsp">Study Materials</a></li>
                                                <li><a href="qna.jsp">Q/A Forum</a></li>
                                                <li class="button-header"><a href="<%= logoutUrl %>" class="btn btn3">Log Out</a></li>
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
                                    <h1 data-animation="fadeInLeft" data-delay="0.2s">Study Materials</h1>
                                    <p data-animation="fadeInLeft" data-delay="0.4s">Access notes, lecture guides, and reference resources.</p>
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

            <!-- Faculty / Admin Upload Form -->
            <% if (!"student".equals(userRole)) { %>
                <div class="card mb-5 shadow-sm border-0">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0 text-white"><i class="fas fa-file-upload mr-2"></i> Add Study Material / Resource Link</h5>
                    </div>
                    <div class="card-body">
                        <form action="study-material.jsp" method="POST">
                            <div class="row">
                                <div class="col-md-4 form-group">
                                    <label><strong>Subject</strong></label>
                                    <input type="text" name="subject" class="form-control" placeholder="e.g. Python Programming" required>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label><strong>Target Degree</strong></label>
                                    <select name="degree" class="form-control">
                                        <option value="All">All Degrees</option>
                                        <option value="B.Sc">B.Sc</option>
                                        <option value="M.Sc">M.Sc</option>
                                        <option value="B.A.">B.A.</option>
                                        <option value="M.A.">M.A.</option>
                                    </select>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label><strong>Material Title</strong></label>
                                    <input type="text" name="title" class="form-control" placeholder="e.g. Week 4 Lecture Notes" required>
                                </div>
                                <div class="col-md-8 form-group">
                                    <label><strong>Resource URL / Document Link</strong></label>
                                    <input type="url" name="resource_url" class="form-control" placeholder="https://..." required>
                                </div>
                                <div class="col-md-4 form-group">
                                    <label><strong>Description (Optional)</strong></label>
                                    <input type="text" name="description" class="form-control" placeholder="Brief summary...">
                                </div>
                            </div>
                            <button type="submit" name="submit_material" value="1" class="btn btn-success">Publish Material</button>
                        </form>
                    </div>
                </div>
            <% } %>

            <!-- Materials Grid -->
            <h4 class="mb-4"><i class="fas fa-book-reader text-primary mr-2"></i> Available Materials</h4>
            <div class="row">
                <%
                try (Connection con = getDBConnection();
                     Statement st = con.createStatement();
                     ResultSet rs = st.executeQuery("SELECT title, subject, degree, description, resource_url, uploaded_by, DATE_FORMAT(created_at, '%b %d, %Y') as pub_date FROM study_materials ORDER BY id DESC")) {
                    boolean hasMaterials = false;
                    while (rs.next()) {
                        hasMaterials = true;
                        String mTitle = rs.getString("title");
                        String mSubject = rs.getString("subject");
                        String mDegree = rs.getString("degree");
                        String mDesc = rs.getString("description");
                        String mUrl = rs.getString("resource_url");
                        String mUploader = rs.getString("uploaded_by");
                        String mDate = rs.getString("pub_date");
                %>
                    <div class="col-lg-4 col-md-6 mb-4">
                        <div class="card material-card border-0 p-4">
                            <div>
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="badge badge-primary"><%= escapeHtml(mSubject) %></span>
                                    <span class="badge badge-secondary"><%= escapeHtml(mDegree) %></span>
                                </div>
                                <h5 class="card-title text-dark"><%= escapeHtml(mTitle) %></h5>
                                <p class="card-text text-muted small"><%= escapeHtml(mDesc != null && !mDesc.isEmpty() ? mDesc : "Course reference material and tutorial resources.") %></p>
                            </div>
                            <div class="mt-3 pt-3 border-top">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <small class="text-muted"><i class="fas fa-user-circle mr-1"></i> <%= escapeHtml(mUploader) %></small>
                                    <small class="text-muted"><%= escapeHtml(mDate) %></small>
                                </div>
                                <a href="<%= escapeHtml(mUrl) %>" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-primary btn-block">
                                    <i class="fas fa-external-link-alt mr-1"></i> Open Material
                                </a>
                            </div>
                        </div>
                    </div>
                <%
                    }
                    if (!hasMaterials) {
                %>
                    <div class="col-12 text-center py-5">
                        <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
                        <p class="text-muted">No study materials published yet.</p>
                    </div>
                <%
                    }
                } catch (Exception e) {
                %>
                    <div class="col-12 alert alert-danger">Error loading study materials: <%= escapeHtml(e.getMessage()) %></div>
                <%
                }
                %>
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
