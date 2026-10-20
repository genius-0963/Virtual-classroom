FROM tomcat:9.0-jdk11-openjdk-slim

# Clean up default tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/examples /usr/local/tomcat/webapps/docs

# Copy web application directly to ROOT
COPY . /usr/local/tomcat/webapps/ROOT/

# Ensure MySQL connector is in Tomcat's system lib
RUN cp /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/mysql-connector-j-*.jar /usr/local/tomcat/lib/

EXPOSE 8080

# Dynamically configure Tomcat port if $PORT is injected by cloud platforms (e.g., Render)
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]

