#!/bin/bash
# Скрипт установки git hooks для автоматической проверки безопасности
# Использование: ./setup-hooks.sh

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Установка git hooks для LaTeX-Mermaid${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Проверка, что мы в git репозитории
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Ошибка: не git репозиторий${NC}"
    exit 1
fi

# Проверка наличия папки git-hooks
if [ ! -d "git-hooks" ]; then
    echo -e "${YELLOW}⚠️  Ошибка: папка git-hooks не найдена${NC}"
    exit 1
fi

# Создать директорию .git/hooks если не существует
mkdir -p .git/hooks

# Установить pre-commit hook
HOOK_SOURCE="git-hooks/pre-commit"
HOOK_DEST=".git/hooks/pre-commit"

if [ -f "$HOOK_DEST" ]; then
    echo -e "${YELLOW}⚠️  Файл $HOOK_DEST уже существует${NC}"
    read -p "   Перезаписать? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}   Установка отменена${NC}"
        exit 0
    fi
    rm "$HOOK_DEST"
fi

# Создать символическую ссылку
ln -s "../../$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_SOURCE"

echo -e "${GREEN}✓ Pre-commit hook установлен${NC}"
echo ""
echo -e "${BLUE}Что делает этот hook:${NC}"
echo -e "  • Проверяет .tex файлы перед коммитом"
echo -e "  • Использует scripts/validate-tex.sh для валидации"
echo -e "  • Блокирует коммит при обнаружении проблем безопасности"
echo ""
echo -e "${BLUE}Альтернатива: pre-commit framework${NC}"
echo -e "  Для более продвинутой настройки используйте:"
echo -e "  ${GREEN}pip install pre-commit${NC}"
echo -e "  ${GREEN}pre-commit install${NC}"
echo -e "  (См. .pre-commit-config.yaml)"
echo ""
echo -e "${GREEN}✅ Установка завершена!${NC}"
