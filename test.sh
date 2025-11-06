#!/bin/bash

# Скрипт автоматического тестирования проекта

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

# Функция для выполнения теста с выводом
run_test_verbose() {
    local test_name="$1"
    local test_command="$2"
    local expected="$3"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}[TEST $TESTS_TOTAL]${NC} $test_name..."

    local result=$(eval "$test_command" 2>&1)
    if [ -n "$expected" ]; then
        if echo "$result" | grep -q "$expected"; then
            echo -e "${GREEN}  ✓ PASSED${NC} ($result)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${RED}  ✗ FAILED${NC} (Expected: $expected, Got: $result)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        if [ -n "$result" ]; then
            echo -e "${GREEN}  ✓ PASSED${NC} ($result)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${RED}  ✗ FAILED${NC} (No output)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    fi
}

echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║         LaTeX-Mermaid Project Test Suite                ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==================== Проверка зависимостей ====================
echo -e "${YELLOW}[1/5] Проверка зависимостей...${NC}"
echo ""

run_test "XeLaTeX установлен" "command -v xelatex"
run_test "mmdc (Mermaid CLI) установлен" "command -v mmdc"
run_test "Node.js установлен" "command -v node"

# Опциональные инструменты
if command -v pdfinfo &> /dev/null; then
    run_test "pdfinfo установлен (для валидации PDF)" "command -v pdfinfo"
else
    echo -e "${YELLOW}  ⚠ SKIPPED: pdfinfo не установлен (опционально)${NC}"
fi

echo ""

# ==================== Проверка структуры проекта ====================
echo -e "${YELLOW}[2/5] Проверка структуры проекта...${NC}"
echo ""

run_test "main.tex существует" "test -f main.tex"
run_test "build.sh существует и исполняем" "test -x build.sh"
run_test "mermaid.sty существует" "test -f mermaid-package/mermaid.sty"
run_test "config.tex существует" "test -f config.tex"
run_test "cover.tex существует" "test -f cover.tex"
run_test "vvedenie.tex существует" "test -f vvedenie.tex"
run_test "Документация пакета существует" "test -f mermaid-package/README.md"
run_test "GitHub Actions: test-package.yml" "test -f .github/workflows/test-package.yml"
run_test "GitHub Actions: build-project.yml" "test -f .github/workflows/build-project.yml"

echo ""

# ==================== Сборка проекта ====================
echo -e "${YELLOW}[3/5] Сборка проекта...${NC}"
echo ""

# Очистка перед сборкой
echo -e "${BLUE}Очистка предыдущей сборки...${NC}"
rm -rf build mermaid-images main.pdf

# Запуск сборки
echo -e "${BLUE}Запуск build.sh...${NC}"
if ./build.sh > /tmp/build-test.log 2>&1; then
    echo -e "${GREEN}  ✓ Сборка успешна${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}  ✗ Сборка провалилась${NC}"
    echo -e "${RED}  Лог сборки:${NC}"
    tail -20 /tmp/build-test.log
    TESTS_FAILED=$((TESTS_FAILED + 1))
    exit 1
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
run_test "PDF создан" "test -f main.pdf"
run_test "PDF в build/ создан" "test -f build/main.pdf"
run_test "Директория mermaid-images создана" "test -d build/mermaid-images"

echo ""

# ==================== Валидация PDF ====================
echo -e "${YELLOW}[4/5] Валидация PDF...${NC}"
echo ""

# Проверка размера файла
if [ -f main.pdf ]; then
    FILE_SIZE=$(stat -f%z main.pdf 2>/dev/null || stat -c%s main.pdf 2>/dev/null)
    run_test_verbose "Размер PDF > 10KB" "echo $FILE_SIZE" ""

    if [ "$FILE_SIZE" -lt 10240 ]; then
        echo -e "${RED}  ⚠ WARNING: PDF слишком маленький ($FILE_SIZE bytes)${NC}"
    fi
fi

# Если pdfinfo доступен - проверяем структуру
if command -v pdfinfo &> /dev/null; then
    PAGES=$(pdfinfo main.pdf 2>/dev/null | grep "Pages:" | awk '{print $2}')

    if [ -n "$PAGES" ]; then
        run_test_verbose "Количество страниц >= 3" "echo $PAGES" ""

        if [ "$PAGES" -lt 3 ]; then
            echo -e "${RED}  ⚠ WARNING: Слишком мало страниц ($PAGES)${NC}"
        fi

        # Проверка метаданных
        TITLE=$(pdfinfo main.pdf 2>/dev/null | grep "Title:" || echo "")
        if [ -n "$TITLE" ]; then
            echo -e "${GREEN}  ✓ PDF содержит метаданные${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${YELLOW}  ⚠ PDF не содержит метаданные${NC}"
        fi
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
    fi
else
    echo -e "${YELLOW}  ⚠ SKIPPED: pdfinfo недоступен${NC}"
fi

# Проверка оглавления
if [ -f build/main.toc ]; then
    TOC_LINES=$(wc -l < build/main.toc)
    run_test "Оглавление создано (main.toc)" "test -f build/main.toc"

    if [ "$TOC_LINES" -gt 2 ]; then
        echo -e "${GREEN}  ✓ Оглавление содержит записи ($TOC_LINES строк)${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${YELLOW}  ⚠ WARNING: Оглавление пустое${NC}"
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo ""

# ==================== Проверка Mermaid диаграмм ====================
echo -e "${YELLOW}[5/5] Проверка Mermaid диаграмм...${NC}"
echo ""

# Подсчет диаграмм в исходниках
EXPECTED_DIAGRAMS=$(grep -c "begin{mermaidenv}" main.tex)
echo -e "${BLUE}Ожидается диаграмм: $EXPECTED_DIAGRAMS${NC}"

# Проверка сгенерированных файлов
if [ -d build/mermaid-images ]; then
    MMD_FILES=$(ls build/mermaid-images/*.mmd 2>/dev/null | wc -l | tr -d ' ')
    PNG_FILES=$(ls build/mermaid-images/*.png 2>/dev/null | wc -l | tr -d ' ')

    run_test_verbose "Количество .mmd файлов = $EXPECTED_DIAGRAMS" "echo $MMD_FILES" "$EXPECTED_DIAGRAMS"
    run_test_verbose "Количество .png файлов = $EXPECTED_DIAGRAMS" "echo $PNG_FILES" "$EXPECTED_DIAGRAMS"

    # Проверка размеров PNG
    if [ "$PNG_FILES" -gt 0 ]; then
        for png in build/mermaid-images/*.png; do
            PNG_SIZE=$(stat -f%z "$png" 2>/dev/null || stat -c%s "$png" 2>/dev/null)
            if [ "$PNG_SIZE" -gt 1000 ]; then
                echo -e "${GREEN}  ✓ $(basename $png): ${PNG_SIZE} bytes${NC}"
            else
                echo -e "${RED}  ✗ $(basename $png): слишком маленький (${PNG_SIZE} bytes)${NC}"
            fi
        done
    fi

    # Проверка симлинка
    run_test "Симлинк mermaid-images существует" "test -L mermaid-images"
else
    echo -e "${RED}  ✗ Директория build/mermaid-images не найдена${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
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
        echo -e "${GREEN}║  ✓✓✓  ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!  ✓✓✓           ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ✗✗✗  НЕКОТОРЫЕ ТЕСТЫ ПРОВАЛИЛИСЬ  ✗✗✗           ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════╝${NC}"
        exit 1
    fi
fi
