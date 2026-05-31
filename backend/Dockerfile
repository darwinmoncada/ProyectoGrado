# Etapa 1: Compilar el frontend (requiere contexto raíz que incluya /frontend)
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend ./
RUN npm run build

# Etapa 2: Compilar el backend y empacar los recursos del frontend
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY backend/pom.xml ./
COPY backend/src ./src
COPY --from=frontend-build /app/frontend/dist ./src/main/resources/static
RUN apk add --no-cache maven
RUN mvn clean package -DskipTests

# Etapa 3: Imagen de ejecución
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=build /app/target/*.jar app.jar
COPY backend/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
RUN chown appuser:appgroup app.jar /app/entrypoint.sh
USER appuser
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
