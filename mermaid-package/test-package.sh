#!/bin/bash

# Тестирование пакета mermaid.sty

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Счетчики тестов
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Определяем директорию скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Функция для выполнения теста
run_test() {
    local test_name="$1"
    local test_command="$2"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}[TEST $TESTS_TOTAL]${NC} $test_name..."

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}  ✗ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║         Mermaid Package Test Suite v1.0.0               ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==================== Проверка структуры пакета ====================
echo -e "${YELLOW}[1/5] Проверка структуры пакета...${NC}"
echo ""

run_test "mermaid.sty существует" "test -f mermaid.sty"
run_test "README.md существует" "test -f README.md"
run_test "MERMAID_USAGE.md существует" "test -f MERMAID_USAGE.md"
run_test "ERROR_HANDLING.md существует" "test -f ERROR_HANDLING.md"
run_test "CHANGES.md существует" "test -f CHANGES.md"
run_test "examples/ директория существует" "test -d examples"
run_test "test-minimal.tex существует" "test -f test-minimal.tex"

echo ""

# ==================== Проверка зависимостей ====================
echo -e "${YELLOW}[2/5] Проверка зависимостей...${NC}"
echo ""

run_test "XeLaTeX установлен" "command -v xelatex"
run_test "mmdc установлен" "command -v mmdc"

echo ""

# ==================== Проверка синтаксиса пакета ====================
echo -e "${YELLOW}[3/5] Проверка синтаксиса LaTeX пакета...${NC}"
echo ""

# Проверяем что пакет содержит необходимые элементы
run_test "Пакет содержит \\ProvidesPackage" "grep -q '\\\\ProvidesPackage{mermaid}' mermaid.sty"
run_test "Пакет содержит версию" "grep -q 'v1\\.0\\.0' mermaid.sty"
run_test "Пакет содержит опции outputdir" "grep -q 'DeclareStringOption.*outputdir' mermaid.sty"
run_test "Пакет содержит опции mermaiddir" "grep -q 'DeclareStringOption.*mermaiddir' mermaid.sty"
run_test "Пакет содержит опции verbose" "grep -q 'DeclareBoolOption.*verbose' mermaid.sty"
run_test "Пакет содержит окружение mermaidenv" "grep -q '\\\\newenvironment{mermaidenv}' mermaid.sty"

echo ""

# ==================== Тест минимального документа ====================
echo -e "${YELLOW}[4/5] Тест компиляции минимального документа...${NC}"
echo ""

# Очистка
rm -rf test-output
mkdir -p test-output

echo -e "${BLUE}Компиляция test-minimal.tex...${NC}"
if xelatex --shell-escape -output-directory=test-output -interaction=nonstopmode test-minimal.tex > test-output/compile.log 2>&1; then
    echo -e "${GREEN}  ✓ Первая компиляция успешна${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}  ✗ Компиляция провалилась${NC}"
    echo -e "${RED}  Последние строки лога:${NC}"
    tail -20 test-output/compile.log
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""

run_test "PDF создан" "test -f test-output/test-minimal.pdf"
run_test "Mermaid директория создана" "test -d test-output/mermaid-images"
run_test "Mermaid .mmd файл создан" "test -f test-output/mermaid-images/mermaid-1.mmd"
run_test "Mermaid .png файл создан" "test -f test-output/mermaid-images/mermaid-1.mmd.png"

# Проверка размера PNG
if [ -f test-output/mermaid-images/mermaid-1.mmd.png ]; then
    PNG_SIZE=$(stat -f%z test-output/mermaid-images/mermaid-1.mmd.png 2>/dev/null || stat -c%s test-output/mermaid-images/mermaid-1.mmd.png 2>/dev/null)
    if [ "$PNG_SIZE" -gt 1000 ]; then
        echo -e "${GREEN}  ✓ PNG размер корректен: ${PNG_SIZE} bytes${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}  ✗ PNG слишком маленький: ${PNG_SIZE} bytes${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo ""

# ==================== Тест примеров ====================
echo -e "${YELLOW}[5/5] Проверка примеров...${NC}"
echo ""

run_test "example-custom-dirs.tex существует" "test -f examples/example-custom-dirs.tex"

# Проверяем что пример компилируется
if [ -f examples/example-custom-dirs.tex ]; then
    echo -e "${BLUE}Компиляция example-custom-dirs.tex...${NC}"
    rm -rf output diagrams
    mkdir -p output

    # Пример использует outputdir=output, поэтому компилируем с -output-directory=output
    xelatex --shell-escape -output-directory=output -interaction=nonstopmode examples/example-custom-dirs.tex > output/compile.log 2>&1

    # Проверяем результат по наличию PDF, не по exit code (могут быть warnings)
    if [ -f output/example-custom-dirs.pdf ]; then
        echo -e "${GREEN}  ✓ Пример скомпилирован${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))

        # Проверяем что используются кастомные директории
        if [ -d output/diagrams ]; then
            echo -e "${GREEN}  ✓ Кастомная директория 'diagrams' создана${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}  ✗ Кастомная директория не создана${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
    else
        echo -e "${RED}  ✗ Компиляция примера провалилась${NC}"
        echo -e "${RED}  Последние строки лога:${NC}"
        tail -20 output/compile.log
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo ""

# ==================== Итоги ====================
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                    Результаты тестов                     ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Всего тестов:   ${BLUE}$TESTS_TOTAL${NC}"
echo -e "  Пройдено:       ${GREEN}$TESTS_PASSED${NC}"
echo -e "  Провалено:      ${RED}$TESTS_FAILED${NC}"
echo ""

# Вычисляем процент успеха
if [ "$TESTS_TOTAL" -gt 0 ]; then
    SUCCESS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    echo -e "  Успешность:     ${BLUE}${SUCCESS_RATE}%${NC}"
    echo ""

    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✓✓✓  ВСЕ ТЕСТЫ ПАКЕТА ПРОЙДЕНЫ!  ✓✓✓            ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BLUE}Очистка временных файлов...${NC}"
        rm -rf test-output output diagrams mermaid-images
        exit 0
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ✗✗✗  НЕКОТОРЫЕ ТЕСТЫ ПРОВАЛИЛИСЬ  ✗✗✗           ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Временные файлы сохранены в:${NC}"
        echo -e "  - test-output/ (минимальный тест)"
        echo -e "  - output/ (пример с кастомными директориями)"
        exit 1
    fi
fi
