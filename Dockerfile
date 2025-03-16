# Use OpenJDK as the base image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the WAR file from the target folder into the container
COPY target/PA-0.0.1-SNAPSHOT.war app.war

# Expose the application port (Spring Boot default is 8080)
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.war"]
