#!/bin/bash
set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_DIR="/app/config"
CONFIG_FILE="$CONFIG_DIR/config.toml"
SECRET_FILE="$CONFIG_DIR/secret.txt"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   MTProto Proxy (mtg) Auto-Setup${NC}"
echo -e "${BLUE}========================================${NC}"

# Проверяем, что mtg установлен
if ! command -v mtg &> /dev/null; then
    echo -e "${YELLOW}❌ mtg not found!${NC}"
    exit 1
fi

# Проверяем, существует ли уже конфигурация
if [ -f "$CONFIG_FILE" ] && [ -f "$SECRET_FILE" ]; then
    echo -e "${GREEN}📁 Найдена существующая конфигурация${NC}"
    MTG_SECRET=$(cat "$SECRET_FILE")
    echo -e "${GREEN}✅ Секрет загружен из сохранённой конфигурации${NC}"
else
    echo -e "${YELLOW}🔐 Создание новой конфигурации...${NC}"
    
    # Создаём директорию для конфига
    mkdir -p "$CONFIG_DIR"
    
    # Генерируем секрет с указанным доменом
    echo -e "${YELLOW}🔐 Генерация секрета для домена $DOMAIN...${NC}"
    MTG_SECRET=$(mtg generate-secret --hex "$DOMAIN")
    
    # Сохраняем секрет в файл
    echo "$MTG_SECRET" > "$SECRET_FILE"
    echo -e "${GREEN}✅ Секрет сгенерирован и сохранён${NC}"
    
    # Создаём конфигурационный файл
    cat > "$CONFIG_FILE" <<EOF
secret = "$MTG_SECRET"
bind-to = "0.0.0.0:3128"
EOF
    echo -e "${GREEN}📄 Конфигурация создана и сохранена: $CONFIG_FILE${NC}"
fi

# Запускаем doctor для проверки
echo -e "${YELLOW}🔍 Запуск doctor...${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
mtg doctor "$CONFIG_FILE" || true
echo -e "${BLUE}----------------------------------------${NC}"

echo -e "${GREEN}🚀 Запуск прокси...${NC}"

# Запускаем mtg в фоне
mtg run --bind 0.0.0.0:3128 "$CONFIG_FILE" &
MTG_PID=$!

sleep 2

# Получаем IP сервера
SERVER_IP=$(curl -s ifconfig.me)

# Внешний порт берём из env
EXTERNAL_PORT="${PORT:-443}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ ПРОКСИ УСПЕШНО ЗАПУЩЕН${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "🌐 Сервер: ${BLUE}$SERVER_IP${NC}"
echo -e "🔌 Порт: ${BLUE}$EXTERNAL_PORT${NC}"
echo -e "🔑 Секрет: ${YELLOW}$MTG_SECRET${NC}"
echo ""
echo -e "${GREEN}🔗 ССЫЛКА ДЛЯ TELEGRAM (нажмите для автонастройки):${NC}"
echo -e "${BLUE}tg://proxy?server=$SERVER_IP&port=$EXTERNAL_PORT&secret=$MTG_SECRET${NC}"
echo ""
echo -e "${YELLOW}📝 Для просмотра логов: docker logs -f mtg-proxy${NC}"
echo -e "${YELLOW}🛑 Для остановки: docker-compose down${NC}"
echo -e "${YELLOW}💾 Конфигурация сохранена, секрет не изменится при перезапуске${NC}"
echo -e "${YELLOW}⚙️  Для смены домена или порта отредактируйте .env и выполните:${NC}"
echo -e "${YELLOW}   docker-compose down && docker-compose up -d${NC}"
echo -e "${GREEN}========================================${NC}"

wait $MTG_PID