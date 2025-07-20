# Dockerfile pour NFC4Care Backend
FROM openjdk:17-jdk-slim

# Installer Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail
WORKDIR /app

# Copier le fichier pom.xml
COPY pom.xml .

# Télécharger les dépendances
RUN mvn dependency:go-offline -B

# Copier le code source
COPY src src

# Compiler l'application
RUN mvn clean package -DskipTests

# Exposer le port
EXPOSE 8080

# Commande de démarrage
CMD ["java", "-jar", "target/nfc4care-backend-1.0.0.jar"] 