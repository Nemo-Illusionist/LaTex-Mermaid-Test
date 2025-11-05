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

# Компилируем с выводом временных файлов в build/
# Модифицированный mermaid.sty теперь корректно работает с -output-directory
xelatex --shell-escape -output-directory="$BUILD_DIR" main.tex

# Проверяем успешность сборки
if [ $? -eq 0 ]; then
    # Копируем PDF в корень проекта
    if [ -f "$BUILD_DIR/main.pdf" ]; then
        cp "$BUILD_DIR/main.pdf" .
        echo -e "${GREEN}✓ Сборка успешна! PDF создан: main.pdf${NC}"
        echo -e "${GREEN}  Временные файлы в $BUILD_DIR/${NC}"
    else
        echo -e "${RED}✗ Ошибка: PDF файл не создан${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Ошибка при компиляции. Смотрите $BUILD_DIR/main.log${NC}"
    exit 1
fi
