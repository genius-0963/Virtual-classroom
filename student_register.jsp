<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.sql.*, java.util.*"%>
<%@ include file="db.jspf" %>
<!doctype html>
<html class="no-js" lang="zxx">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Student Registration</title>
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
        .login-form select.custom-select-field {
            width: 100%;
            height: 50px;
            margin-bottom: 20px;
            padding: 0 15px;
            border: 1px solid #e5e5e5;
            border-radius: 5px;
            color: #495057;
            background: #fff;
            display: block;
        }
    </style>

    <script>
        var courseMap = {
            "B.Sc": ["Computer Application", "Computer Science", "Data Science"],
            "M.Sc": ["Computer Science", "Computer Application"],
            "B.A.": ["English", "Psychology"],
            "M.A.": ["English", "Psychology"]
        };

        function check() {
            var p1 = document.getElementById("password").value;
            var p2 = document.getElementById("confirm_password").value;
            var msg = document.getElementById("message");
            if (p2.length === 0) {
                msg.innerHTML = "";
            } else if (p1 === p2) {
                msg.style.color = "green";
                msg.innerHTML = "Password matched!";
            } else {
                msg.style.color = "red";
                msg.innerHTML = "Password does not match!";
            }
        }

        function onDegreeChange() {
            var degSelect = document.getElementById("degree");
            var courseSelect = document.getElementById("course");
            var yearSelect = document.getElementById("year");
            var selectedDeg = degSelect.value;

            // Reset course options
            courseSelect.innerHTML = '<option value=""> Select course </option>';
            if (courseMap[selectedDeg]) {
                for (var i = 0; i < courseMap[selectedDeg].length; i++) {
                    var opt = document.createElement("option");
                    opt.value = courseMap[selectedDeg][i];
                    opt.textContent = courseMap[selectedDeg][i];
                    courseSelect.appendChild(opt);
                }
            }

            // Adjust years
            yearSelect.innerHTML = '<option value=""> Select year </option><option value="1"> I </option><option value="2"> II </option>';
            if (selectedDeg.startsWith("B")) {
                var opt3 = document.createElement("option");
                opt3.value = "3";
                opt3.textContent = "III";
                yearSelect.appendChild(opt3);
            }
        }
    </script>
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

    <%
    String regError = null;

    // Handle registration submission only on POST
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("submit") != null) {
        String no = request.getParameter("roll_no");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String degree = request.getParameter("degree");
        String course = request.getParameter("course");
        String year = request.getParameter("year");

        if (password != null && !password.equals(confirmPassword)) {
            regError = "Passwords do not match.";
        } else if (no != null && name != null && email != null && password != null && degree != null && course != null && year != null) {
            Connection con = null;
            PreparedStatement pstmt = null;
            try {
                con = getDBConnection();
                String sql = "insert into student (roll_no, name, email_id, password, degree, course, year, is_approved) values (?, ?, ?, ?, ?, ?, ?, 0)";
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, no.trim());
                pstmt.setString(2, name.trim());
                pstmt.setString(3, email.trim());
                pstmt.setString(4, hashPassword(password));
                pstmt.setString(5, degree.trim());
                pstmt.setString(6, course.trim());
                pstmt.setInt(7, Integer.parseInt(year.trim()));
                pstmt.executeUpdate();

                session.setAttribute("reg_success", "Registration request sent successfully! You can login once approved by Administrator.");
                response.sendRedirect("student_login.jsp");
                return;
            } catch (SQLIntegrityConstraintViolationException sqle) {
                regError = "A student with Roll No " + no + " is already registered.";
            } catch (Exception e) {
                regError = "Error during registration: " + e.getMessage();
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch(Exception ignored) {}
                if (con != null) try { con.close(); } catch(Exception ignored) {}
            }
        }
    }
    %>
    <%@ include file="quick_login_box.jspf" %>

    <main class="login-body">
        <form class="form-default" name="myform" action="student_register.jsp" method="POST">
            <div class="login-form reg">
                <div class="logo-login">
                    <a href="index.jsp"><img src="assets/img/logo/loder.png" alt=""></a>
                </div>
                <h2>Student Registration</h2>
                <p>*All fields are mandatory</p>

                <% if (regError != null) { %>
                    <p style="color: red; font-weight: bold;"><%= regError %></p>
                <% } %>

                <div class="form-input">
                    <input type="text" name="roll_no" id="roll_no" placeholder="Roll No" required value="<%= request.getParameter("roll_no") != null ? request.getParameter("roll_no") : "" %>">
                </div>
                <div class="form-input">
                    <input type="text" name="name" id="name" placeholder="Full name" required value="<%= request.getParameter("name") != null ? request.getParameter("name") : "" %>">
                </div>
                <div class="form-input">
                    <input type="email" name="email" id="email" placeholder="Email ID" required value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
                </div>
                <div class="form-input">
                    <input type="password" id="password" name="password" placeholder="Password" required>
                </div>
                <div class="form-input">
                    <input type="password" id="confirm_password" name="confirm_password" placeholder="Confirm Password" onkeyup="check();" required>
                    <span id="message"></span>
                </div>

                <div class="form-input">
                    <select name="degree" id="degree" class="custom-select-field" required onchange="onDegreeChange();">
                        <option value=""> Select degree </option>
                        <option value="B.Sc"> B.Sc </option>
                        <option value="M.Sc"> M.Sc </option>
                        <option value="B.A."> B.A. </option>
                        <option value="M.A."> M.A. </option>
                    </select>
                </div>

                <div class="form-input">
                    <select name="course" id="course" class="custom-select-field" required>
                        <option value=""> Select course </option>
                        <option value="Computer Application"> Computer Application </option>
                        <option value="Computer Science"> Computer Science </option>
                        <option value="Data Science"> Data Science </option>
                        <option value="English"> English </option>
                        <option value="Psychology"> Psychology </option>
                    </select>
                </div>

                <div class="form-input">
                    <select name="year" id="year" class="custom-select-field" required>
                        <option value=""> Select year </option>
                        <option value="1"> I </option>
                        <option value="2"> II </option>
                        <option value="3"> III </option>
                    </select>
                </div>

                <div class="form-input pt-30">
                    <input type="submit" name="submit" value="Send Request">
                </div>
                <a href="student_login.jsp" class="registration">Already have an account? <b>Login here</b></a>
            </div>
        </form>
    </main>

    <script src="./assets/js/vendor/modernizr-3.5.0.min.js"></script>
    <script src="./assets/js/vendor/jquery-1.12.4.min.js"></script>
    <script src="./assets/js/popper.min.js"></script>
    <script src="./assets/js/bootstrap.min.js"></script>
    <script src="./assets/js/plugins.js"></script>
    <script src="./assets/js/main.js"></script>
</body>
</html>