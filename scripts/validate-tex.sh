#!/bin/bash

# Скрипт валидации безопасности .tex файлов
# Проверяет наличие потенциально опасных команд

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Счётчики
WARNINGS=0
ERRORS=0
CHECKS=0

# Функция для проверки
check_pattern() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    local severity="$4"  # WARNING or ERROR

    CHECKS=$((CHECKS + 1))

    if grep -q "$pattern" "$file" 2>/dev/null; then
        if [ "$severity" = "ERROR" ]; then
            echo -e "${RED}[ERROR]${NC} $description"
            echo -e "${RED}  Найдено:${NC}"
            grep -n "$pattern" "$file" | head -5 | sed 's/^/    /'
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${YELLOW}[WARNING]${NC} $description"
            echo -e "${YELLOW}  Найдено:${NC}"
            grep -n "$pattern" "$file" | head -5 | sed 's/^/    /'
            WARNINGS=$((WARNINGS + 1))
        fi
        return 1
    else
        echo -e "${GREEN}[OK]${NC} $description"
        return 0
    fi
}

# Проверка аргументов
if [ $# -eq 0 ]; then
    echo -e "${RED}Использование: $0 <file.tex>${NC}"
    echo ""
    echo "Пример:"
    echo "  $0 main.tex"
    echo "  $0 document.tex"
    exit 1
fi

FILE="$1"

# Проверка существования файла
if [ ! -f "$FILE" ]; then
    echo -e "${RED}Ошибка: Файл '$FILE' не найден${NC}"
    exit 1
fi

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Проверка безопасности LaTeX документа               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Файл:${NC} $FILE"
echo ""

# ==================== Критические проверки ====================
echo -e "${YELLOW}[1/3] Критические угрозы...${NC}"
echo ""

check_pattern "$FILE" "rm\s\+-rf" \
    "Команда удаления файлов (rm -rf)" \
    "ERROR"

check_pattern "$FILE" "\\\\write18.*rm" \
    "Удаление через write18" \
    "ERROR"

check_pattern "$FILE" "\\\\write18.*curl" \
    "Сетевые запросы через curl" \
    "ERROR"

check_pattern "$FILE" "\\\\write18.*wget" \
    "Загрузка файлов через wget" \
    "ERROR"

check_pattern "$FILE" "\\\\write18.*bash" \
    "Запуск bash скриптов" \
    "ERROR"

check_pattern "$FILE" "\\\\write18.*sh\s" \
    "Запуск shell скриптов" \
    "ERROR"

check_pattern "$FILE" "\\\\write18.*python" \
    "Запуск Python скриптов" \
    "ERROR"

check_pattern "$FILE" "sudo" \
    "Команды с sudo (повышение привилегий)" \
    "ERROR"

echo ""

# ==================== Подозрительные паттерны ====================
echo -e "${YELLOW}[2/3] Подозрительные паттерны...${NC}"
echo ""

check_pattern "$FILE" "\\\\write18" \
    "Использование \\write18 (выполнение команд)" \
    "WARNING"

check_pattern "$FILE" "\\\\immediate\\\\write18" \
    "Немедленное выполнение команд (\\immediate\\write18)" \
    "WARNING"

check_pattern "$FILE" "\\\\input{/.*}" \
    "Чтение абсолютных путей" \
    "WARNING"

check_pattern "$FILE" "\\\\include{/.*}" \
    "Включение файлов по абсолютному пути" \
    "WARNING"

check_pattern "$FILE" "\\\$(" \
    "Подстановка команд оболочки \$(...)" \
    "WARNING"

check_pattern "$FILE" "eval" \
    "Использование eval" \
    "WARNING"

echo ""

# ==================== Проверка известных безопасных команд ====================
echo -e "${YELLOW}[3/3] Проверка разрешённых команд...${NC}"
echo ""

# Проверяем что используется только mmdc (для mermaid)
if grep -q "\\\\write18" "$FILE"; then
    echo -e "${BLUE}[INFO]${NC} Найдены \\write18 команды, проверяем их:"

    # Извлекаем все write18 команды
    grep "\\\\write18" "$FILE" | while IFS= read -r line; do
        echo "  $line"

        # Проверяем что это только mmdc
        if echo "$line" | grep -q "mmdc"; then
            echo -e "    ${GREEN}✓${NC} Разрешённая команда (mmdc)"
        elif echo "$line" | grep -qE "bibtex|makeindex|kpsewhich"; then
            echo -e "    ${GREEN}✓${NC} Стандартная LaTeX команда"
        else
            echo -e "    ${YELLOW}⚠${NC} Нестандартная команда - требуется ревью"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
fi

echo ""

# ==================== Итоги ====================
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Результаты проверки                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Выполнено проверок: ${BLUE}$CHECKS${NC}"
echo -e "  Предупреждений:     ${YELLOW}$WARNINGS${NC}"
echo -e "  Ошибок:             ${RED}$ERRORS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗✗✗  ОПАСНО! Найдены критические угрозы  ✗✗✗    ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}НЕ КОМПИЛИРУЙТЕ этот файл с --shell-escape!${NC}"
    echo ""
    exit 2
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠⚠⚠  ВНИМАНИЕ! Требуется ревью  ⚠⚠⚠           ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Файл содержит команды выполнения.${NC}"
    echo -e "${YELLOW}Убедитесь что вы доверяете источнику!${NC}"
    echo ""
    exit 1
else
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓✓✓  Проверка пройдена успешно  ✓✓✓            ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Файл выглядит безопасным для компиляции.${NC}"
    echo ""
    exit 0
fi
