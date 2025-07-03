#!/bin/bash

# Ellis API Starter Script
# Este script facilita o gerenciamento da aplicação Ellis API com Docker

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Verifica se Docker está rodando
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker não está rodando. Inicie o Docker primeiro."
        exit 1
    fi
}

# Verifica se Docker Compose está disponível
check_compose() {
    if ! command -v docker-compose > /dev/null 2>&1; then
        print_error "Docker Compose não está instalado."
        exit 1
    fi
}

# Função para mostrar ajuda
show_help() {
    echo "Ellis API - Script de Gerenciamento"
    echo ""
    echo "Uso: ./start.sh [COMANDO]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  dev         - Inicia em modo desenvolvimento"
    echo "  prod        - Inicia em modo produção"
    echo "  stop        - Para todos os serviços"
    echo "  restart     - Reinicia os serviços"
    echo "  logs        - Mostra logs da aplicação"
    echo "  status      - Mostra status dos containers"
    echo "  clean       - Remove containers e limpa sistema"
    echo "  backup      - Faz backup do banco de dados"
    echo "  shell       - Acessa shell do container"
    echo "  help        - Mostra esta ajuda"
    echo ""
}

# Função para desenvolvimento
start_dev() {
    print_header "Iniciando Ellis API - Modo Desenvolvimento"
    
    print_status "Construindo imagem..."
    docker-compose build
    
    print_status "Iniciando serviços..."
    docker-compose up -d
    
    print_status "Aguardando serviços ficarem prontos..."
    sleep 10
    
    print_status "Ellis API está rodando!"
    echo ""
    echo "🌐 API: http://localhost:8000"
    echo "📚 Docs: http://localhost:8000/docs"
    echo "📖 ReDoc: http://localhost:8000/redoc"
    echo ""
    echo "Para ver os logs: ./start.sh logs"
    echo "Para parar: ./start.sh stop"
}

# Função para produção
start_prod() {
    print_header "Iniciando Ellis API - Modo Produção"
    
    print_status "Construindo imagem..."
    docker-compose -f docker-compose.prod.yml build
    
    print_status "Iniciando serviços..."
    docker-compose -f docker-compose.prod.yml up -d
    
    print_status "Aguardando serviços ficarem prontos..."
    sleep 15
    
    print_status "Ellis API está rodando em produção!"
    echo ""
    echo "🌐 API: http://localhost:8000"
    echo "🔒 Nginx: http://localhost:80"
    echo ""
    echo "Para ver os logs: ./start.sh logs"
    echo "Para parar: ./start.sh stop"
}

# Função para parar serviços
stop_services() {
    print_header "Parando Serviços"
    
    print_status "Parando desenvolvimento..."
    docker-compose down || true
    
    print_status "Parando produção..."
    docker-compose -f docker-compose.prod.yml down || true
    
    print_status "Serviços parados!"
}

# Função para reiniciar
restart_services() {
    print_header "Reiniciando Serviços"
    
    stop_services
    sleep 3
    
    if [ -f "docker-compose.prod.yml" ] && docker-compose -f docker-compose.prod.yml ps -q | grep -q .; then
        start_prod
    else
        start_dev
    fi
}

# Função para mostrar logs
show_logs() {
    print_header "Logs da Aplicação"
    docker-compose logs -f escola-api
}

# Função para mostrar status
show_status() {
    print_header "Status dos Containers"
    
    echo "Desenvolvimento:"
    docker-compose ps || echo "Nenhum serviço de desenvolvimento rodando"
    
    echo ""
    echo "Produção:"
    docker-compose -f docker-compose.prod.yml ps || echo "Nenhum serviço de produção rodando"
}

# Função para limpeza
clean_system() {
    print_header "Limpando Sistema"
    
    print_warning "Isso irá remover todos os containers e volumes!"
    read -p "Tem certeza? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removendo containers..."
        docker-compose down -v || true
        docker-compose -f docker-compose.prod.yml down -v || true
        
        print_status "Limpando sistema Docker..."
        docker system prune -f
        
        print_status "Limpeza concluída!"
    else
        print_status "Operação cancelada."
    fi
}

# Função para backup
backup_database() {
    print_header "Backup do Banco de Dados"
    
    if [ -f "escola.db" ]; then
        BACKUP_NAME="escola.db.backup.$(date +%Y%m%d_%H%M%S)"
        cp escola.db "$BACKUP_NAME"
        print_status "Backup criado: $BACKUP_NAME"
    else
        print_error "Arquivo escola.db não encontrado!"
    fi
}

# Função para acessar shell
access_shell() {
    print_header "Acessando Shell do Container"
    
    if docker-compose ps -q escola-api > /dev/null 2>&1; then
        docker-compose exec escola-api sh
    else
        print_error "Container escola-api não está rodando!"
        print_status "Inicie a aplicação primeiro: ./start.sh dev"
    fi
}

# Função principal
main() {
    check_docker
    check_compose
    
    case "${1:-help}" in
        "dev")
            start_dev
            ;;
        "prod")
            start_prod
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "clean")
            clean_system
            ;;
        "backup")
            backup_database
            ;;
        "shell")
            access_shell
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Executa função principal
main "$@" 