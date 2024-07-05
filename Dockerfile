FROM eclipse-temurin:17-jdk-alpine
WORKDIR /
ADD /target/*.jar configServer.jar
EXPOSE 9000
ENTRYPOINT ["java","-jar","configServer.jar"]
