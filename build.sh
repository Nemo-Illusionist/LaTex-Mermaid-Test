#!/bin/bash

# Скрипт для сборки LaTeX проекта

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Создаём директорию для временных файлов
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"

echo -e "${YELLOW}Сборка проекта...${NC}"

# Компилируем в корне (для работы mermaid)
xelatex --shell-escape main.tex

# Проверяем успешность сборки
if [ $? -eq 0 ]; then
    # Переносим временные файлы в build/
    mv -f main.aux main.log main.out main.toc "$BUILD_DIR/" 2>/dev/null

    # Проверяем что PDF создался
    if [ -f "main.pdf" ]; then
        echo -e "${GREEN}✓ Сборка успешна! PDF создан: main.pdf${NC}"
        echo -e "${GREEN}  Временные файлы перемещены в $BUILD_DIR/${NC}"
    else
        echo -e "${RED}✗ Ошибка: PDF файл не создан${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Ошибка при компиляции. Смотрите main.log${NC}"
    # Переносим лог для удобства
    mv -f main.log "$BUILD_DIR/" 2>/dev/null
    exit 1
fi
