# Обработка ошибок в mermaid.sty v1.0.0

## Обзор улучшений

Версия 1.0.0 добавляет продвинутую обработку ошибок для более удобной диагностики проблем при генерации диаграмм.

## Новые возможности

### 1. Проверка наличия mmdc при загрузке

Пакет автоматически проверяет наличие `mmdc` при загрузке документа:

```latex
\usepackage{mermaid}
```

**В логе компиляции:**
```
Package mermaid Info: mmdc found and ready to use
```

**Если mmdc не найден:**
```
Package mermaid Warning: mmdc (Mermaid CLI) not found!
    Please install: npm install -g @mermaid-js/mermaid-cli
```

### 2. Детальные сообщения об ошибках

При ошибке генерации диаграммы:

**Вместо общего сообщения:**
```
Error: Mermaid diagram generation failed
```

**Теперь показывается:**
```
Mermaid Error: Failed to generate diagram
File: mermaid-images/mermaid-1.mmd
Check log: mermaid-images/mermaid-1.mmd.log
```

### 3. Режим verbose для диагностики

Включите verbose режим для детального логирования:

```latex
\usepackage[verbose]{mermaid}
```

В этом режиме:
- Все ошибки `mmdc` записываются в `.log` файлы
- Каждая диаграмма имеет свой лог: `mermaid-1.mmd.log`, `mermaid-2.mmd.log`, и т.д.
- Выводится дополнительная информация о процессе генерации

**Пример лог-файла** (`mermaid-1.mmd.log`):
```
Error: syntax error at line 2
  graph TD
    A[Start] -> B  // Неверный синтаксис!
```

### 4. Информационные сообщения

При генерации каждой диаграммы выводится информация:

```
Package mermaid Info: Generating diagram: mermaid-images/mermaid-1.mmd
```

В verbose режиме:
```
Package mermaid Info: Generating diagram with verbose logging: mermaid-images/mermaid-1.mmd
```

## Типичные ошибки и решения

### Ошибка 1: mmdc не найден

**Сообщение:**
```
Package mermaid Warning: mmdc (Mermaid CLI) not found!
```

**Решение:**
```bash
npm install -g @mermaid-js/mermaid-cli
```

**Проверка:**
```bash
mmdc --version
```

### Ошибка 2: Синтаксическая ошибка в диаграмме

**Сообщение:**
```
Package mermaid Error: Failed to generate diagram: mermaid-images/mermaid-1.mmd
Check mermaid-images/mermaid-1.mmd.log for details
```

**Решение:**
1. Включите verbose режим: `\usepackage[verbose]{mermaid}`
2. Перекомпилируйте документ
3. Откройте указанный `.log` файл
4. Исправьте синтаксис диаграммы согласно ошибке

**Проверка синтаксиса:**
- Используйте [Mermaid Live Editor](https://mermaid.live/)
- Проверьте закрывающие скобки и кавычки
- Убедитесь в правильности типа диаграммы

### Ошибка 3: Puppeteer/Chromium проблемы

**Сообщение в .log:**
```
Error: Failed to launch chrome!
spawn EACCES
```

**Решение:**
Создайте `puppeteer-config.json`:
```json
{
  "args": [
    "--no-sandbox",
    "--disable-setuid-sandbox",
    "--disable-dev-shm-usage"
  ]
}
```

### Ошибка 4: Недостаточно памяти

**Сообщение в .log:**
```
Error: page.goto: Navigation timeout of 30000 ms exceeded
```

**Решение:**
1. Упростите диаграмму
2. Разбейте сложную диаграмму на несколько простых
3. Увеличьте память для Node.js:
```bash
export NODE_OPTIONS="--max-old-space-size=4096"
```

### Ошибка 5: Файл не найден

**Сообщение:**
```
Package mermaid Error: Failed to generate diagram
File: mermaid-images/mermaid-1.mmd
```

**Возможные причины:**
- Нет прав на запись в директорию
- Опция `outputdir` не совпадает с `-output-directory`
- Директория была удалена во время компиляции

**Решение:**
1. Проверьте права доступа: `ls -la build/`
2. Убедитесь что `outputdir` совпадает:
```latex
% Если компилируете: xelatex -output-directory=out document.tex
\usepackage[outputdir=out]{mermaid}
```

## Workflow диагностики

### Шаг 1: Базовая диагностика

```bash
# Проверка наличия mmdc
command -v mmdc

# Проверка версии
mmdc --version

# Тестовая генерация
echo 'graph TD; A-->B' > test.mmd
mmdc -i test.mmd -o test.png
```

### Шаг 2: Включить verbose режим

```latex
\documentclass{article}
\usepackage[verbose]{mermaid}  % <-- Добавить verbose

\begin{document}
\begin{mermaidenv}[width=10cm]
graph TD
  A --> B
\end{mermaidenv}
\end{document}
```

### Шаг 3: Проверить логи

```bash
# Лог LaTeX компиляции
cat build/main.log | grep -i "mermaid\|error"

# Логи mmdc (если verbose включен)
cat build/mermaid-images/*.log
```

### Шаг 4: Изолировать проблему

Создайте минимальный тестовый документ:

```latex
\documentclass{article}
\usepackage[verbose]{mermaid}

\begin{document}

\section{Test}

\begin{mermaidenv}[width=5cm]
graph TD
  A[Simple] --> B[Test]
\end{mermaidenv}

\end{document}
```

Если работает - проблема в сложности диаграммы или конфликте пакетов.

## Примеры использования

### Пример 1: Базовое использование с обработкой ошибок

```latex
\documentclass{article}
\usepackage{mermaid}

\begin{document}

% Эта диаграмма сработает
\begin{mermaidenv}[width=10cm]
graph TD
  A --> B
\end{mermaidenv}

% Эта диаграмма вызовет ошибку (неверный синтаксис)
% Будет показано сообщение с указанием файла
\begin{mermaidenv}[width=10cm]
graph TD
  A -> B  % Неправильный синтаксис!
\end{mermaidenv}

\end{document}
```

### Пример 2: Verbose режим для разработки

```latex
\documentclass{article}
\usepackage[verbose]{mermaid}  % Детальное логирование

\begin{document}

% При компиляции будут созданы .log файлы
% для каждой диаграммы
\begin{mermaidenv}[width=10cm]
sequenceDiagram
  Alice->>Bob: Hello
  Bob-->>Alice: Hi!
\end{mermaidenv}

% Если есть ошибка, проверьте:
% build/mermaid-images/mermaid-1.mmd.log

\end{document}
```

### Пример 3: Обработка отсутствия mmdc

```latex
\documentclass{article}
\usepackage{mermaid}

\begin{document}

% Если mmdc не установлен, будет показано:
% "Mermaid Error: mmdc not found
%  Install: npm install -g @mermaid-js/mermaid-cli"

\begin{mermaidenv}[width=10cm]
graph LR
  A --> B
\end{mermaidenv}

\end{document}
```

## API обработки ошибок

### Флаг доступности mmdc

Внутренний флаг `\ifmermaid@mmdc@available` указывает, доступен ли mmdc:

```latex
\ifmermaid@mmdc@available
  % mmdc доступен
\else
  % mmdc не найден
\fi
```

### Сообщения в лог

Пакет использует три уровня сообщений:

1. **Info** - информационные сообщения
```latex
\PackageInfo{mermaid}{mmdc found and ready to use}
```

2. **Warning** - предупреждения (не прерывают компиляцию)
```latex
\PackageWarning{mermaid}{mmdc not found!}
```

3. **Error** - ошибки (требуют действий)
```latex
\PackageError{mermaid}{Failed to generate diagram}
```

## Лучшие практики

### 1. Используйте verbose только при разработке

```latex
% При разработке
\usepackage[verbose]{mermaid}

% В финальной версии
\usepackage{mermaid}
```

### 2. Проверяйте синтаксис заранее

Используйте [Mermaid Live Editor](https://mermaid.live/) перед вставкой в документ.

### 3. Храните логи при ошибках

```bash
# Сохранить логи для анализа
cp build/main.log error-report.log
cp build/mermaid-images/*.log ./errors/
```

### 4. Тестируйте инкрементально

Добавляйте диаграммы по одной и компилируйте после каждой.

### 5. Используйте version control

```bash
# Коммитите работающие версии
git add main.tex
git commit -m "Add working sequence diagram"
```

## Changelog

### v1.0.0 (2025-01-05)

**Добавлено:**
- ✅ Проверка наличия mmdc при загрузке
- ✅ Детальные сообщения об ошибках с указанием файлов
- ✅ Опция `verbose` для логирования ошибок mmdc
- ✅ Информационные сообщения о процессе генерации
- ✅ Graceful fallback при отсутствии mmdc

**Улучшено:**
- ✅ Сообщения об ошибках теперь включают путь к лог-файлу
- ✅ Проверка условий перед генерацией

## Известные ограничения

1. **Windows пути**: На Windows может потребоваться `\` вместо `/`
2. **Кириллица в путях**: Могут быть проблемы с путями, содержащими не-ASCII символы
3. **Одновременная компиляция**: Параллельная компиляция может вызвать race conditions

## Получение помощи

Если проблема не решается:

1. Проверьте [GitHub Issues](https://github.com/user/repo/issues)
2. Включите verbose режим и сохраните все логи
3. Создайте минимальный воспроизводимый пример
4. Укажите версии: XeLaTeX, Node.js, mmdc, mermaid.sty

---

**Документация актуальна для:** mermaid.sty v1.0.0
**Последнее обновление:** 2025-01-05
