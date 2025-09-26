#!/bin/bash

# setup.sh: Script para configurar y desplegar el servidor de la To-Do List en Ubuntu.
# Se detiene si cualquier comando falla.
set -e

# --- Variables de Configuración ---
DB_USER="todolist_user"
DB_NAME="todolist_db"
# Generamos una contraseña segura para la base de datos
DB_PASS=$(openssl rand -base64 16)

# --- Colores para la Salida ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}--- Iniciando configuración del servidor To-Do List ---${NC}"

# --- PASO 1: Comprobar e instalar dependencias ---

echo -e "\n${YELLOW}1. Verificando dependencias...${NC}"

# Comprobar Go
if ! command -v go &> /dev/null; then
    echo "Go no está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y golang-go
    echo -e "${GREEN}Go instalado exitosamente.${NC}"
else
    echo "Go ya está instalado."
fi

# Comprobar PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "PostgreSQL no está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y postgresql postgresql-client
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    echo -e "${GREEN}PostgreSQL instalado y activado exitosamente.${NC}"
else
    echo "PostgreSQL ya está instalado."
fi

# Comprobar la herramienta de migración 'migrate'
if ! command -v migrate &> /dev/null; then
    echo "La herramienta 'migrate' no está instalada. Instalando con Go..."
    # Aseguramos que el directorio de binarios de Go esté en el PATH
    export PATH=$PATH:$(go env GOPATH)/bin
    go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
    # Verificamos de nuevo
    if ! command -v migrate &> /dev/null; then
         echo "Error: La instalación de 'migrate' falló. Asegúrate de que '$(go env GOPATH)/bin' esté en tu \$PATH."
         exit 1
    fi
    echo -e "${GREEN}'migrate' instalado exitosamente.${NC}"
else
    echo "La herramienta 'migrate' ya está instalada."
fi

# --- PASO 2: Crear base de datos y archivo .env ---

echo -e "\n${YELLOW}2. Configurando la base de datos y las credenciales...${NC}"

# Crear usuario y base de datos en PostgreSQL
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
    echo "El usuario de la base de datos '$DB_USER' ya existe. Actualizando su contraseña..."
    sudo -u postgres psql -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';"
else
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
    echo "Usuario de la base de datos '$DB_USER' creado."
fi

if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo "La base de datos '$DB_NAME' ya existe."
else
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
    echo "Base de datos '$DB_NAME' creada."
fi

# Crear el archivo .env
echo "Creando archivo .env..."
DB_URL="postgres://${DB_USER}:${DB_PASS}@localhost:5432/${DB_NAME}?sslmode=disable"
JWT_SECRET=$(openssl rand -hex 32)

cat > .env << EOF
# Variables de entorno para el servidor To-Do List

# URL de conexión a la base de datos PostgreSQL
DB_URL="$DB_URL"

# Secreto para firmar los tokens JWT (generado aleatoriamente)
JWT_SECRET="$JWT_SECRET"

# Puerto en el que correrá el servidor
PORT="8080"
EOF

echo -e "${GREEN}Archivo .env creado exitosamente.${NC}"

# --- PASO 3: Ejecutar migraciones ---

echo -e "\n${YELLOW}3. Ejecutando migraciones de la base de datos...${NC}"
export PATH=$PATH:$(go env GOPATH)/bin
migrate -database "$DB_URL" -path migrations up
echo -e "${GREEN}Migraciones aplicadas exitosamente.${NC}"

# --- PASO 4: Compilar y levantar el servidor ---

echo -e "\n${YELLOW}4. Compilando y levantando el servidor...${NC}"

echo "Compilando el proyecto..."
go build -o todolist_server ./cmd/api

echo -e "${GREEN}¡Compilación completa!${NC}"
echo -e "\n${GREEN}--- Servidor listo para iniciar ---${NC}"
echo "Ejecuta el siguiente comando para iniciar el servidor:"
echo -e "${YELLOW}./todolist_server${NC}"