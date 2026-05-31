# Etapa 1: Build
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN apk add --no-cache maven
RUN mvn clean package -DskipTests

# Etapa 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=build /app/target/*.jar app.jar

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

RUN chown appuser:appgroup app.jar /app/entrypoint.sh
USER appuser

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
