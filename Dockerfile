# Stage 1: Build stage
FROM maven:3.8.4-openjdk-11 AS build

WORKDIR /app

# Copy the pom.xml and download the dependencies
COPY pom.xml .

RUN mvn dependency:go-offline

# Copy the rest of the application code and build the JAR file
COPY src ./src

RUN mvn clean package -DskipTests

# Stage 2: Runtime stage
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/spring-boot-web.jar app.jar


#-----------------------Code to push .jar Artifact in Nexus repository------------------------

# Set environment variables for Nexus credentials and repository
      ENV NEXUS_URL=http://52.90.56.214:8081/repository/maven-releases/
      ENV NEXUS_USERNAME=admin
      ENV NEXUS_PASSWORD=dipak
# Install curl for uploading artifacts
      RUN apt-get update && apt-get install -y curl
# Upload the artifact to Nexus Repository
      RUN curl -u ${NEXUS_USERNAME}:${NEXUS_PASSWORD} --upload-file app.jar ${NEXUS_URL}

#-----------------------Code to push .jar Artifact in Nexus repository------------------------


# Expose the application port
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
