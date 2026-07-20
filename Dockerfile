FROM eclipse-temurin:17-jdk
    
RUN apt-get update && apt-get install -y maven

WORKDIR /app


COPY pom.xml .

COPY src ./src

RUN mvn clean package -DskipTests

RUN cp target/*.jar  app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"] 
