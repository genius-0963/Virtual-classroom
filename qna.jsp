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

    // Handle posting a new question
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("submit_question") != null) {
        String title = request.getParameter("title");
        String subject = request.getParameter("subject");
        String content = request.getParameter("content");

        if (title != null && subject != null && content != null && !title.trim().isEmpty() && !content.trim().isEmpty()) {
            try (Connection con = getDBConnection();
                 PreparedStatement ps = con.prepareStatement("INSERT INTO questions (author_name, author_role, subject, title, content) VALUES (?, ?, ?, ?, ?)")) {
                ps.setString(1, userName);
                ps.setString(2, userRole);
                ps.setString(3, subject.trim());
                ps.setString(4, title.trim());
                ps.setString(5, content.trim());
                ps.executeUpdate();
                actionMsg = "Question posted successfully!";
            } catch (Exception e) {
                errorMsg = "Failed to post question: " + e.getMessage();
            }
        } else {
            errorMsg = "Please fill in all question fields.";
        }
    }

    // Handle posting an answer
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("submit_answer") != null) {
        String qId = request.getParameter("question_id");
        String answerContent = request.getParameter("answer_content");

        if (qId != null && answerContent != null && !answerContent.trim().isEmpty()) {
            try (Connection con = getDBConnection();
                 PreparedStatement ps = con.prepareStatement("INSERT INTO answers (question_id, author_name, author_role, content) VALUES (?, ?, ?, ?)")) {
                ps.setInt(1, Integer.parseInt(qId.trim()));
                ps.setString(2, userName);
                ps.setString(3, userRole);
                ps.setString(4, answerContent.trim());
                ps.executeUpdate();
                actionMsg = "Answer submitted successfully!";
            } catch (Exception e) {
                errorMsg = "Failed to submit answer: " + e.getMessage();
            }
        }
    }
%>
<!doctype html>
<html class="no-js" lang="zxx">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Q/A Forum - Virtual Classroom</title>
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
        .question-card {
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
            margin-bottom: 25px;
            padding: 25px;
            border-left: 4px solid #1f2b7b;
        }
        .answer-box {
            background: #f8f9fa;
            border-radius: 6px;
            padding: 15px;
            margin-top: 15px;
            border-left: 3px solid #28a745;
        }
        .badge-role {
            font-size: 0.75rem;
            padding: 4px 8px;
            border-radius: 4px;
            text-transform: capitalize;
        }
        .badge-faculty { background-color: #28a745; color: white; }
        .badge-student { background-color: #17a2b8; color: white; }
        .badge-admin { background-color: #dc3545; color: white; }
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
                                                <li><a href="study-material.jsp">Study Materials</a></li>
                                                <li class="active"><a href="qna.jsp">Q/A Forum</a></li>
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
                                    <h1 data-animation="fadeInLeft" data-delay="0.2s">Q/A Forum</h1>
                                    <p data-animation="fadeInLeft" data-delay="0.4s">Logged in as <strong><%= escapeHtml(userName) %></strong> (<%= escapeHtml(userRole) %>). Ask questions and learn together.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <div class="container py-5">
            <% if (actionMsg != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= escapeHtml(actionMsg) %>
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            <% } %>
            <% if (errorMsg != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= escapeHtml(errorMsg) %>
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            <% } %>

            <div class="row">
                <!-- Ask Question Box -->
                <div class="col-lg-4 mb-4">
                    <div class="card shadow-sm border-0">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0 text-white"><i class="fas fa-question-circle mr-2"></i> Ask a Question</h5>
                        </div>
                        <div class="card-body">
                            <form action="qna.jsp" method="POST">
                                <div class="form-group">
                                    <label><strong>Subject / Topic</strong></label>
                                    <select name="subject" class="form-control" required>
                                        <option value="Computer Science">Computer Science</option>
                                        <option value="Python Programming">Python Programming</option>
                                        <option value="JAVA Programming">JAVA Programming</option>
                                        <option value="Data Science">Data Science</option>
                                        <option value="Software Engineering">Software Engineering</option>
                                        <option value="General Doubt">General Doubt</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label><strong>Title</strong></label>
                                    <input type="text" name="title" class="form-control" placeholder="What is your question?" required>
                                </div>
                                <div class="form-group">
                                    <label><strong>Details / Context</strong></label>
                                    <textarea name="content" class="form-control" rows="4" placeholder="Provide more details..." required></textarea>
                                </div>
                                <button type="submit" name="submit_question" value="1" class="btn btn-primary btn-block">Post Question</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Questions Stream -->
                <div class="col-lg-8">
                    <h4 class="mb-4"><i class="fas fa-comments text-primary mr-2"></i> Recent Discussions</h4>

                    <%
                    try (Connection con = getDBConnection();
                         Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT id, author_name, author_role, subject, title, content, DATE_FORMAT(created_at, '%b %d, %Y %H:%i') as posted_date FROM questions ORDER BY id DESC")) {
                        boolean hasQuestions = false;
                        while (rs.next()) {
                            hasQuestions = true;
                            int qId = rs.getInt("id");
                            String qAuthor = rs.getString("author_name");
                            String qRole = rs.getString("author_role");
                            String qSub = rs.getString("subject");
                            String qTitle = rs.getString("title");
                            String qContent = rs.getString("content");
                            String qDate = rs.getString("posted_date");
                    %>
                        <div class="question-card">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="badge badge-info"><%= escapeHtml(qSub) %></span>
                                <small class="text-muted"><%= escapeHtml(qDate) %></small>
                            </div>
                            <h4 class="mb-2"><%= escapeHtml(qTitle) %></h4>
                            <p class="text-secondary mb-3"><%= escapeHtml(qContent) %></p>
                            <div class="d-flex align-items-center mb-3">
                                <small class="text-muted mr-2">Asked by:</small>
                                <span class="font-weight-bold mr-2"><%= escapeHtml(qAuthor) %></span>
                                <span class="badge-role <%= "faculty".equalsIgnoreCase(qRole) ? "badge-faculty" : "badge-student" %>"><%= escapeHtml(qRole) %></span>
                            </div>

                            <!-- Answers Section -->
                            <div class="border-top pt-3">
                                <h6><strong>Answers:</strong></h6>
                                <%
                                try (PreparedStatement psAns = con.prepareStatement("SELECT author_name, author_role, content, DATE_FORMAT(created_at, '%b %d, %Y %H:%i') as ans_date FROM answers WHERE question_id = ? ORDER BY id ASC")) {
                                    psAns.setInt(1, qId);
                                    try (ResultSet rsAns = psAns.executeQuery()) {
                                        boolean hasAns = false;
                                        while (rsAns.next()) {
                                            hasAns = true;
                                            String aAuthor = rsAns.getString("author_name");
                                            String aRole = rsAns.getString("author_role");
                                            String aContent = rsAns.getString("content");
                                            String aDate = rsAns.getString("ans_date");
                                %>
                                            <div class="answer-box">
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <div>
                                                        <strong><%= escapeHtml(aAuthor) %></strong>
                                                        <span class="badge-role ml-1 <%= "faculty".equalsIgnoreCase(aRole) ? "badge-faculty" : "badge-student" %>"><%= escapeHtml(aRole) %></span>
                                                    </div>
                                                    <small class="text-muted"><%= escapeHtml(aDate) %></small>
                                                </div>
                                                <p class="mb-0 text-dark"><%= escapeHtml(aContent) %></p>
                                            </div>
                                <%
                                        }
                                        if (!hasAns) {
                                %>
                                            <p class="text-muted small mb-2">No answers yet. Be the first to answer!</p>
                                <%
                                        }
                                    }
                                }
                                %>

                                <!-- Reply Form -->
                                <form action="qna.jsp" method="POST" class="mt-3">
                                    <input type="hidden" name="question_id" value="<%= qId %>">
                                    <div class="input-group">
                                        <input type="text" name="answer_content" class="form-control form-control-sm" placeholder="Write an answer..." required>
                                        <div class="input-group-append">
                                            <button class="btn btn-sm btn-success" type="submit" name="submit_answer" value="1">Reply</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    <%
                        }
                        if (!hasQuestions) {
                    %>
                        <div class="alert alert-light text-center py-5">
                            <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                            <p class="text-muted">No questions posted yet. Be the first to start a discussion!</p>
                        </div>
                    <%
                        }
                    } catch (Exception e) {
                    %>
                        <div class="alert alert-danger">Error loading questions: <%= escapeHtml(e.getMessage()) %></div>
                    <%
                    }
                    %>
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
