# Mermaid для LaTeX

Пакет `mermaid.sty` позволяет встраивать диаграммы Mermaid в LaTeX документы.

## Установка зависимостей

```bash
# Установить mermaid-cli (если ещё не установлен)
npm install -g @mermaid-js/mermaid-cli
```

## Использование

### 1. Подключение пакета

```latex
\usepackage[pdf]{mermaid}  % Для PDF вывода
% или
\usepackage[svg]{mermaid}  % Для SVG вывода
```

### 2. Однострочные диаграммы (команда \mermaid)

Для простых однострочных диаграмм используйте команду `\mermaid`:

```latex
\mermaid[\linewidth]{graph TD; A-->B-->C}
```

**Важно:** Команда `\mermaid` не поддерживает многострочный код с переносами строк!

### 3. Многострочные диаграммы (окружение mermaidenv)

Для сложных диаграмм используйте окружение `mermaidenv`:

```latex
\begin{mermaidenv}[\linewidth]
graph TD
  A[Start] --> B{Decision}
  B -->|Yes| C[OK]
  B -->|No| D[Cancel]
\end{mermaidenv}
```

### 4. Параметры размера

Оба варианта принимают опциональный параметр ширины:

```latex
\mermaid[\linewidth]{...}          % Во всю ширину
\mermaid[.5\linewidth]{...}        % Половина ширины
\mermaid[10cm]{...}                % Фиксированный размер

\begin{mermaidenv}[.8\linewidth]   % 80% ширины
...
\end{mermaidenv}
```

## Компиляция

**Обязательно** используйте флаг `--shell-escape` для компиляции:

```bash
# Для английского текста
pdflatex --shell-escape document.tex

# Для русского текста (рекомендуется XeLaTeX)
xelatex --shell-escape document.tex
```

## Примеры

### Английский документ (pdflatex)

```latex
\documentclass{article}
\usepackage[pdf]{mermaid}

\begin{document}

\mermaid[\linewidth]{graph TD; A-->B-->C}

\begin{mermaidenv}[.8\linewidth]
graph LR
  A[Input] --> B[Process]
  B --> C[Output]
\end{mermaidenv}

\end{document}
```

### Русский документ (xelatex)

```latex
\documentclass{article}
\usepackage{fontspec}
\usepackage{polyglossia}
\setdefaultlanguage{russian}
\setmainfont{Arial}

\usepackage[pdf]{mermaid}

\begin{document}

\section*{Пример}

\begin{mermaidenv}[\linewidth]
graph TD
  A[Начало] --> B[Конец]
\end{mermaidenv}

\end{document}
```

## Как это работает

1. Пакет сохраняет Mermaid код во временный `.mmd` файл
2. Запускает `mmdc` (mermaid-cli) для генерации изображения
3. Автоматически вставляет сгенерированное изображение в документ
4. Временные файлы сохраняются в директории `mermaid-images/`

## Устранение проблем

### "command not found: mmdc"

Установите mermaid-cli:
```bash
npm install -g @mermaid-js/mermaid-cli
```

### Русские шрифты не работают

Используйте XeLaTeX вместо pdflatex:
```latex
\usepackage{fontspec}
\usepackage{polyglossia}
\setdefaultlanguage{russian}
\setmainfont{Arial}  % или другой шрифт с кириллицей
```

### Многострочный код в \mermaid не работает

Используйте окружение `mermaidenv` вместо команды `\mermaid` для многострочных диаграмм.
