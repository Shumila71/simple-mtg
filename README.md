# Simple-mtg - Docker Auto-Setup MTProto

Автоматический развёртывание MTProto прокси на базе [mtg](https://github.com/9seconds/mtg).  
Всё, что нужно - указать домен для маскировки и порт (или оставить автоматический выбор).

---

## Особенности

- 🔐 **Секрет генерируется один раз** и сохраняется между перезапусками
- 🌐 **Маскировка под домен** — трафик выглядит как обращение к легитимному HTTPS-сайту
- 🔗 **Готовая ссылка** `tg://proxy?...` сразу в логах после запуска
- 🐳 **Docker Compose** — один файл, никаких зависимостей на хосте
- ⚙️ **Параметры только через `.env`** — не нужно лезть в конфиги вручную

---

## Требования

- Docker и Docker Compose (v2+)
- VPS с внешним IP
- Домен или любой HTTPS-сайт, IP которого совпадает с вашим VPS (или любой для маскировки, но не рекомендуется)

---

## Быстрый старт

```bash
git clone https://github.com/Shumila71/simple-mtg.git
cd simple-mtg
```
Отредактируйте .env:
```
DOMAIN=           # домен, соответствующий IP вашего VPS (для маскировки TLS-трафика)
PORT=             # оставьте пустым для выбора порта 443
```
Запустите:
```
docker compose up -d
```
Получите ссылку для Telegram:
```
docker logs mtg-proxy | grep "tg://proxy"
```

---

Структура проекта
```
.
├── Dockerfile          # Образ на базе nineseconds/mtg:2 + bash + curl
├── docker-compose.yml  # Сервис, volumes, networks
├── entrypoint.sh       # Логика генерации/загрузки конфига и запуска mtg
├── .env                # Переменные окружения (DOMAIN, PORT)
└── LICENSE
```

---

Управление

```
# Запуск
docker compose up -d

# Просмотр логов (включая ссылку и секрет)
docker logs -f mtg-proxy

# Остановка
docker compose down

# Пересоздать с новым доменом/портом
docker compose down && docker compose up -d
```
> [!WARNING]
> Секрет **не меняется** при перезапуске. Для генерации нового секрета удалите volume:
> ```bash
> docker compose down -v && docker compose up -d
> ```

---

## Как это работает

1. При первом запуске `entrypoint.sh` генерирует секрет через `mtg generate-secret --hex $DOMAIN`
2. Секрет и конфиг сохраняются в Docker volume `/app/config`  
3. Запускается `mtg doctor` для самодиагностики
4. Запускается `mtg run` с сохранённым конфигом
5. В логах выводится IP сервера, порт, секрет и готовая ссылка для Telegram

---

## На основе

Docker-обёртка для **[mtg](https://github.com/9seconds/mtg)** by [9seconds](https://github.com/9seconds).
Использует официальный образ: [`nineseconds/mtg:2`](https://hub.docker.com/r/nineseconds/mtg).

---

## Лицензия
MIT 