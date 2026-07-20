
# Stage 1

FROM maven:3.9.6-eclipse-temurin-17-alpine  AS builder 

WORKDIR /build


COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests

# Stage 2 Light weight run time image

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /build/target/*.jar app.jar

RUN addgroup -S testuser && adduser testuser -S testuser -G testuser

USER testuser:testuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"] 
