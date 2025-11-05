#!/bin/bash

# Скрипт для сборки LaTeX проекта

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Создаём директорию для временных файлов
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"

echo -e "${YELLOW}Сборка проекта...${NC}"

# Первая компиляция - генерация Mermaid диаграмм и создание .aux, .toc файлов
echo -e "${BLUE}[1/2] Первая компиляция (генерация диаграмм и вспомогательных файлов)...${NC}"
xelatex --shell-escape -output-directory="$BUILD_DIR" -interaction=nonstopmode main.tex

# Проверяем успешность первой компиляции
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Ошибка при первой компиляции. Смотрите $BUILD_DIR/main.log${NC}"
    exit 1
fi

# Проверяем, нужна ли вторая компиляция (для оглавления и ссылок)
NEED_RERUN=false
if grep -q "Rerun to get cross-references right\|Label(s) may have changed" "$BUILD_DIR/main.log" 2>/dev/null; then
    NEED_RERUN=true
fi

if [ "$NEED_RERUN" = true ]; then
    echo -e "${BLUE}[2/2] Вторая компиляция (обновление оглавления и ссылок)...${NC}"
    xelatex --shell-escape -output-directory="$BUILD_DIR" -interaction=nonstopmode main.tex

    # Проверяем успешность второй компиляции
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Ошибка при второй компиляции. Смотрите $BUILD_DIR/main.log${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}[2/2] Вторая компиляция не требуется${NC}"
fi

# Проверяем что PDF создался
if [ -f "$BUILD_DIR/main.pdf" ]; then
    # Копируем PDF в корень проекта
    cp "$BUILD_DIR/main.pdf" .
    echo -e "${GREEN}✓ Сборка успешна! PDF создан: main.pdf${NC}"
    echo -e "${GREEN}  Временные файлы в $BUILD_DIR/${NC}"

    # Показываем информацию о PDF
    if command -v pdfinfo &> /dev/null; then
        PAGES=$(pdfinfo main.pdf 2>/dev/null | grep "Pages:" | awk '{print $2}')
        if [ -n "$PAGES" ]; then
            echo -e "${GREEN}  Количество страниц: $PAGES${NC}"
        fi
    fi
else
    echo -e "${RED}✗ Ошибка: PDF файл не создан${NC}"
    exit 1
fi
