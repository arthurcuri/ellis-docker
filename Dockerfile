# Use Python Alpine para uma imagem mais leve
FROM python:3.13.5-alpine3.22

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Instala dependências do sistema necessárias para SQLAlchemy
RUN apk add --no-cache gcc musl-dev libffi-dev

# Copia o arquivo de requirements primeiro para aproveitar o cache do Docker
COPY requirements.txt .

# Instala as dependências Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copia todos os arquivos da aplicação
COPY . .

# Cria um usuário não-root para segurança
RUN adduser -D -s /bin/sh appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expõe a porta 8000 (padrão do FastAPI)
EXPOSE 8000

# Comando para iniciar a aplicação
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]