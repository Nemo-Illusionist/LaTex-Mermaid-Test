# Документация пакета mermaid.sty v1.0.0

## Описание

Пакет `mermaid.sty` позволяет интегрировать [Mermaid](https://mermaid.js.org/) диаграммы в LaTeX документы с автоматической генерацией изображений.

## Требования

- **XeLaTeX** или **LuaLaTeX** с опцией `--shell-escape`
- **Node.js** (версия 16+)
- **@mermaid-js/mermaid-cli** (`mmdc`)

### Установка зависимостей

```bash
# Установка Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Проверка установки
mmdc --version
```

## Установка пакета

Скопируйте `mermaid.sty` в директорию вашего проекта или в локальный texmf tree.

## Использование

### Базовое использование

```latex
\documentclass{article}
\usepackage{mermaid}

\begin{document}

% Inline диаграмма
\mermaid[width=5cm]{
  graph TD
    A[Start] --> B[Process]
}

% Multiline диаграмма
\begin{mermaidenv}[width=\linewidth]
graph LR
  A[Input] --> B[Process]
  B --> C[Output]
\end{mermaidenv}

\end{document}
```

**Компиляция:**
```bash
xelatex --shell-escape document.tex
```

### Настройка директорий

#### Опция `outputdir`

Задает имя директории, используемой с `-output-directory`:

```latex
% Если компилируете с: xelatex -output-directory=out document.tex
\usepackage[outputdir=out]{mermaid}
```

**По умолчанию:** `build`

#### Опция `mermaiddir`

Задает имя поддиректории для хранения Mermaid файлов:

```latex
% Mermaid файлы будут в diagrams/
\usepackage[mermaiddir=diagrams]{mermaid}
```

**По умолчанию:** `mermaid-images`

#### Комбинирование опций

```latex
\usepackage[outputdir=build, mermaiddir=img/mermaid]{mermaid}
```

Структура файлов:
```
project/
├── document.tex
└── build/
    ├── document.aux
    ├── document.pdf
    └── img/
        └── mermaid/
            ├── mermaid-1.mmd
            └── mermaid-1.mmd.png
```

### Переопределение настроек в документе

Вы также можете переопределить настройки через команды (до `\usepackage{mermaid}`):

```latex
\documentclass{article}

% Переопределяем дефолтные значения
\renewcommand{\mermaiddir}{custom-diagrams}
\renewcommand{\mermaidoutputdir}{output}

\usepackage{mermaid}

\begin{document}
...
\end{document}
```

## API

### Команда `\mermaid`

**Синтаксис:**
```latex
\mermaid[опции_includegraphics]{код_mermaid}
```

**Параметры:**
- `опции_includegraphics` (опционально) - стандартные опции `\includegraphics`: `width`, `height`, `scale`, `keepaspectratio` и т.д.
- `код_mermaid` - код диаграммы Mermaid (одна строка)

**Примеры:**
```latex
% Естественный размер
\mermaid{graph TD; A-->B}

% Заданная ширина
\mermaid[width=5cm]{graph TD; A-->B}

% Масштаб
\mermaid[scale=0.8]{graph TD; A-->B}

% Сохранение пропорций
\mermaid[width=\linewidth, keepaspectratio]{graph TD; A-->B}
```

### Окружение `mermaidenv`

**Синтаксис:**
```latex
\begin{mermaidenv}[опции_includegraphics]
  код_mermaid
  (многострочный)
\end{mermaidenv}
```

**Параметры:**
- `опции_includegraphics` (опционально) - те же, что и для `\mermaid`

**Примеры:**
```latex
\begin{mermaidenv}[width=\linewidth]
graph TD
  A[Start] --> B{Decision?}
  B -->|Yes| C[Do Something]
  B -->|No| D[Do Nothing]
  C --> E[End]
  D --> E
\end{mermaidenv}
```

### Использование в figure окружении

```latex
\begin{figure}[htbp]
  \centering
  \begin{mermaidenv}[width=0.8\linewidth]
  sequenceDiagram
    participant Alice
    participant Bob
    Alice->>Bob: Hello Bob!
    Bob->>Alice: Hi Alice!
  \end{mermaidenv}
  \caption{Диаграмма последовательности}
  \label{fig:sequence}
\end{figure}
```

## Типы диаграмм Mermaid

Пакет поддерживает все типы диаграмм Mermaid:

### Flowchart (Блок-схема)
```latex
\begin{mermaidenv}[width=10cm]
graph TD
  A[Christmas] -->|Get money| B(Go shopping)
  B --> C{Let me think}
  C -->|One| D[Laptop]
  C -->|Two| E[iPhone]
\end{mermaidenv}
```

### Sequence Diagram (Диаграмма последовательности)
```latex
\begin{mermaidenv}[width=10cm]
sequenceDiagram
  Alice->>John: Hello John!
  John-->>Alice: Great!
\end{mermaidenv}
```

### Class Diagram (Диаграмма классов)
```latex
\begin{mermaidenv}[width=10cm]
classDiagram
  Animal <|-- Duck
  Animal <|-- Fish
  Animal : +int age
  Animal : +String gender
\end{mermaidenv}
```

### State Diagram (Диаграмма состояний)
```latex
\begin{mermaidenv}[width=10cm]
stateDiagram-v2
  [*] --> Still
  Still --> [*]
  Still --> Moving
  Moving --> Still
\end{mermaidenv}
```

### Gantt Chart (Диаграмма Ганта)
```latex
\begin{mermaidenv}[width=\linewidth]
gantt
  title Project Timeline
  section Planning
  Task 1 :a1, 2024-01-01, 30d
  Task 2 :after a1, 20d
\end{mermaidenv}
```

### Pie Chart (Круговая диаграмма)
```latex
\begin{mermaidenv}[width=8cm]
pie
  title Pets adopted by volunteers
  "Dogs" : 386
  "Cats" : 85
  "Rats" : 15
\end{mermaidenv}
```

## Конфигурация Puppeteer

Если у вас проблемы с запуском Chromium (например, в CI окружении), создайте файл `puppeteer-config.json`:

```json
{
  "args": [
    "--no-sandbox",
    "--disable-setuid-sandbox",
    "--disable-dev-shm-usage"
  ]
}
```

Пакет автоматически использует этот файл, если он существует.

## Устранение проблем

### Ошибка "mmdc: command not found"

Установите Mermaid CLI:
```bash
npm install -g @mermaid-js/mermaid-cli
```

### Ошибка "! I can't write on file"

Убедитесь, что:
1. Используете `--shell-escape`
2. Директория существует и доступна для записи
3. Опция `outputdir` совпадает с `-output-directory`

### Диаграмма не отображается

Проверьте:
1. Логи компиляции на наличие ошибок `mmdc`
2. Существование PNG файлов в `mermaid-images/` или `build/mermaid-images/`
3. Корректность синтаксиса Mermaid диаграммы

### Диаграмма генерируется каждый раз

Это нормальное поведение. Для оптимизации можно:
- Использовать `latexmk` с кэшированием
- Создать отдельный скрипт для предварительной генерации диаграмм

## Внутреннее устройство

### Алгоритм работы

1. При загрузке документа пакет создает директорию для Mermaid файлов
2. Для каждой диаграммы:
   - Генерируется уникальное имя файла (`mermaid-1.mmd`, `mermaid-2.mmd`, ...)
   - Код диаграммы сохраняется в `.mmd` файл
   - Вызывается `mmdc` для генерации PNG
   - PNG вставляется через `\includegraphics`

### Структура файлов

**Без `-output-directory`:**
```
project/
├── document.tex
└── mermaid-images/
    ├── mermaid-1.mmd
    └── mermaid-1.mmd.png
```

**С `-output-directory=build`:**
```
project/
├── document.tex
├── mermaid-images → build/mermaid-images/  (симлинк)
└── build/
    ├── document.pdf
    └── mermaid-images/
        ├── mermaid-1.mmd
        └── mermaid-1.mmd.png
```

## Примеры использования

### Минимальный документ

```latex
\documentclass{article}
\usepackage{mermaid}

\begin{document}

\begin{mermaidenv}[width=10cm]
graph TD
  A[Start] --> B[Process]
  B --> C[End]
\end{mermaidenv}

\end{document}
```

### С кастомными настройками

```latex
\documentclass{article}
\usepackage[outputdir=out, mermaiddir=diagrams]{mermaid}
\usepackage{caption}

\begin{document}

\begin{figure}[h]
  \centering
  \begin{mermaidenv}[width=0.9\linewidth]
  graph LR
    A[Input Data] --> B[Process]
    B --> C{Valid?}
    C -->|Yes| D[Save]
    C -->|No| E[Error]
  \end{mermaidenv}
  \caption{Процесс валидации данных}
  \label{fig:validation}
\end{figure}

Как показано на рисунке~\ref{fig:validation}, процесс начинается с входных данных.

\end{document}
```

## Лицензия

MIT License

## Автор

Модифицированная версия для интеграции Mermaid в LaTeX

## Changelog

### v1.0.0 (2025-01-05)
- ✨ Добавлены опции пакета `outputdir` и `mermaiddir`
- ✨ Версионирование пакета
- ✨ Информационные сообщения при загрузке
- ✨ Поддержка `\providecommand` для переопределения
- 🐛 Исправлена работа с `-output-directory`
- 📝 Полная документация

---

**Полезные ссылки:**
- [Mermaid документация](https://mermaid.js.org/)
- [Mermaid Live Editor](https://mermaid.live/) - для тестирования диаграмм
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli)
