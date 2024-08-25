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

# Expose the application port
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
