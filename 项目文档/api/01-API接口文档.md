# Bubble Tea CN API 接口文档

## 概述

本文档提供了 Bubble Tea CN 框架的完整 API 接口文档，包括所有公共接口、类型、函数和方法的详细说明。

## 核心接口

### Model 接口

Model 是应用程序的核心接口，定义了状态和行为。

```go
type Model interface {
    // Init 返回初始命令
    Init() Cmd

    // Update 处理消息并返回更新后的模型和命令
    Update(Msg) (Model, Cmd)

    // View 返回 UI 字符串
    View() string
}
```

#### 方法说明

| 方法 | 返回值 | 说明 |
|------|---------|------|
| `Init()` | `Cmd` | 返回初始命令，用于执行初始 I/O 操作 |
| `Update(msg)` | `(Model, Cmd)` | 处理消息，返回更新后的模型和命令 |
| `View()` | `string` | 根据模型状态渲染 UI |

#### 使用示例

```go
type model struct {
    choices []string
    cursor  int
}

func (m model) Init() tea.Cmd {
    return nil // 无初始命令
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        // 处理键盘输入
        return m, nil
    }
    return m, nil
}

func (m model) View() string {
    // 渲染 UI
    return "Hello, Bubble Tea!"
}
```

### Renderer 接口

Renderer 是渲染器的抽象接口，用于将 UI 渲染到终端。

```go
type renderer interface {
    start()
    stop()
    kill()
    write(string)
    repaint()
    clearScreen()
    altScreen() bool
    enterAltScreen()
    exitAltScreen()
    showCursor()
    hideCursor()
    enableMouseCellMotion()
    disableMouseCellMotion()
    enableMouseAllMotion()
    disableMouseAllMotion()
    enableMouseSGRMode()
    disableMouseSGRMode()
    enableBracketedPaste()
    disableBracketedPaste()
    bracketedPasteActive() bool
    setWindowTitle(string)
    reportFocus() bool
    enableReportFocus()
    disableReportFocus()
    resetLinesRendered()
}
```

#### 方法说明

| 方法 | 返回值 | 说明 |
|------|---------|------|
| `start()` | - | 启动渲染器 |
| `stop()` | - | 停止渲染器，渲染最终帧 |
| `kill()` | - | 停止渲染器，不渲染最终帧 |
| `write(str)` | - | 写入帧到渲染器 |
| `repaint()` | - | 请求完全重绘 |
| `clearScreen()` | - | 清除终端 |
| `altScreen()` | `bool` | 是否在备用屏幕缓冲区 |
| `enterAltScreen()` | - | 进入备用屏幕缓冲区 |
| `exitAltScreen()` | - | 退出备用屏幕缓冲区 |
| `showCursor()` | - | 显示光标 |
| `hideCursor()` | - | 隐藏光标 |
| `enableMouseCellMotion()` | - | 启用鼠标单元格运动跟踪 |
| `disableMouseCellMotion()` | - | 禁用鼠标单元格运动跟踪 |
| `enableMouseAllMotion()` | - | 启用鼠标所有运动跟踪 |
| `disableMouseAllMotion()` | - | 禁用鼠标所有运动跟踪 |
| `enableMouseSGRMode()` | - | 启用鼠标 SGR 扩展模式 |
| `disableMouseSGRMode()` | - | 禁用鼠标 SGR 扩展模式 |
| `enableBracketedPaste()` | - | 启用括号粘贴模式 |
| `disableBracketedPaste()` | - | 禁用括号粘贴模式 |
| `bracketedPasteActive()` | `bool` | 括号粘贴模式是否激活 |
| `setWindowTitle(title)` | - | 设置终端窗口标题 |
| `reportFocus()` | `bool` | 是否报告焦点事件 |
| `enableReportFocus()` | - | 启用焦点事件报告 |
| `disableReportFocus()` | - | 禁用焦点事件报告 |
| `resetLinesRendered()` | - | 重置渲染行数 |

### ExecCommand 接口

ExecCommand 是用于执行外部命令的接口。

```go
type ExecCommand interface {
    Run() error
    SetStdin(io.Reader)
    SetStdout(io.Writer)
    SetStderr(io.Writer)
}
```

#### 方法说明

| 方法 | 参数 | 返回值 | 说明 |
|------|--------|---------|------|
| `Run()` | - | `error` | 执行命令并返回错误 |
| `SetStdin(r)` | `io.Reader` | - | 设置命令的标准输入 |
| `SetStdout(w)` | `io.Writer` | - | 设置命令的标准输出 |
| `SetStderr(w)` | `io.Writer` | - | 设置命令的标准错误 |

#### 使用示例

```go
cmd := exec.Command("vim", "file.txt")

// 设置输入输出
cmd.SetStdin(os.Stdin)
cmd.SetStdout(os.Stdout)
cmd.SetStderr(os.Stderr)

// 执行命令
execCmd := tea.ExecProcess(cmd, func(err error) tea.Msg {
    return ExecFinishedMsg{err: err}
})
```

## 核心类型

### Program 类型

Program 是 Bubble Tea 的核心结构，管理整个应用程序。

```go
type Program struct {
    initialModel Model
    msgs         chan Msg
    errs         chan error
    finished     chan struct{}
    output       io.Writer
    input        io.Reader
    renderer    renderer
    ctx          context.Context
    cancel       context.CancelFunc
    // ... 其他配置字段
}
```

#### 方法说明

| 方法 | 参数 | 返回值 | 说明 |
|------|--------|---------|------|
| `NewProgram(model, opts...)` | `Model, ...ProgramOption` | `*Program` | 创建新程序 |
| `Run()` | - | `(Model, error)` | 运行程序并返回最终模型和错误 |
| `Send(msg)` | `Msg` | - | 发送消息到程序 |
| `Quit()` | - | - | 退出程序 |
| `Kill()` | - | - | 终止程序 |

#### 使用示例

```go
// 创建程序
p := tea.NewProgram(initialModel(),
    tea.WithAltScreen(),
    tea.WithMouseCellMotion(),
)

// 运行程序
finalModel, err := p.Run()
if err != nil {
    log.Fatal(err)
}

// 从外部发送消息
p.Send(tea.QuitMsg{})
```

### Msg 类型

Msg 是任何类型，用于在应用程序中传递信息。

```go
type Msg interface{}
```

#### 内置消息类型

##### QuitMsg

退出消息，指示程序应该退出。

```go
type QuitMsg struct{}
```

##### SuspendMsg

暂停消息，指示程序应该暂停。

```go
type SuspendMsg struct{}
```

##### ResumeMsg

恢复消息，指示程序已经从暂停状态恢复。

```go
type ResumeMsg struct{}
```

##### InterruptMsg

中断消息，指示程序应该中断。

```go
type InterruptMsg struct{}
```

##### WindowSizeMsg

窗口大小消息，报告终端的尺寸。

```go
type WindowSizeMsg struct {
    Width  int
    Height int
}
```

##### FocusMsg

焦点消息，指示终端获得了焦点。

```go
type FocusMsg struct{}
```

##### BlurMsg

模糊消息，指示终端失去了焦点。

```go
type BlurMsg struct{}
```

### KeyMsg 类型

KeyMsg 包含键盘输入的信息。

```go
type KeyMsg Key

type Key struct {
    Type  KeyType
    Runes []rune
    Alt   bool
    Paste bool
}

type KeyType int
```

#### 字段说明

| 字段 | 类型 | 说明 |
|------|--------|------|
| `Type` | `KeyType` | 按键类型（如 KeyEnter、KeyRunes） |
| `Runes` | `[]rune` | 按键的字符 |
| `Alt` | `bool` | 是否按下了 Alt 键 |
| `Paste` | `bool` | 是否来自粘贴操作 |

#### 方法说明

| 方法 | 返回值 | 说明 |
|------|---------|------|
| `String()` | `string` | 返回按键的字符串表示 |

#### 按键类型常量

| 常量 | 值 | 说明 |
|--------|-----|------|
| `KeyRunes` | 0 | 普通字符 |
| `KeyEnter` | 1 | 回车键 |
| `KeySpace` | 2 | 空格键 |
| `KeyBackspace` | 3 | 退格键 |
| `KeyTab` | 4 | Tab 键 |
| `KeyEscape` | 5 | ESC 键 |
| `KeyUp` | 6 | 上箭头 |
| `KeyDown` | 7 | 下箭头 |
| `KeyLeft` | 8 | 左箭头 |
| `KeyRight` | 9 | 右箭头 |
| `KeyCtrlC` | 10 | Ctrl+C |
| 等等... | - | - |

#### 使用示例

```go
func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "enter":
            // 处理回车键
            return m, nil
        case "q":
            return m, tea.Quit
        }
        
        switch msg.Type {
        case tea.KeyUp:
            // 处理上箭头
            return m, nil
        case tea.KeyRunes:
            // 处理普通字符
            fmt.Printf("输入: %s\n", string(msg.Runes))
            return m, nil
        }
    }
    return m, nil
}
```

### MouseMsg 类型

MouseMsg 包含鼠标事件的信息。

```go
type MouseMsg MouseEvent

type MouseEvent struct {
    X      int
    Y      int
    Shift  bool
    Alt    bool
    Ctrl   bool
    Action MouseAction
    Button MouseButton
}

type MouseAction int

type MouseButton int
```

#### 字段说明

| 字段 | 类型 | 说明 |
|------|--------|------|
| `X` | `int` | 鼠标 X 坐标 |
| `Y` | `int` | 鼠标 Y 坐标 |
| `Shift` | `bool` | 是否按下了 Shift 键 |
| `Alt` | `bool` | 是否按下了 Alt 键 |
| `Ctrl` | `bool` | 是否按下了 Ctrl 键 |
| `Action` | `MouseAction` | 鼠标操作类型 |
| `Button` | `MouseButton` | 鼠标按钮类型 |

#### 方法说明

| 方法 | 返回值 | 说明 |
|------|---------|------|
| `String()` | `string` | 返回鼠标事件的字符串表示 |
| `IsWheel()` | `bool` | 是否为滚轮事件 |

#### 鼠标操作常量

| 常量 | 值 | 说明 |
|--------|-----|------|
| `MouseActionPress` | 0 | 按下 |
| `MouseActionRelease` | 1 | 释放 |
| `MouseActionMotion` | 2 | 移动 |

#### 鼠标按钮常量

| 常量 | 值 | 说明 |
|--------|-----|------|
| `MouseButtonLeft` | 1 | 左键 |
| `MouseButtonMiddle` | 2 | 中键 |
| `MouseButtonRight` | 3 | 右键 |
| `MouseButtonWheelUp` | 4 | 滚轮向上 |
| `MouseButtonWheelDown` | 5 | 滚轮向下 |
| `MouseButtonWheelLeft` | 6 | 滚轮向左 |
| `MouseButtonWheelRight` | 7 | 滚轮向右 |

#### 使用示例

```go
func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.MouseMsg:
        if msg.Button == tea.MouseButtonLeft && msg.Action == tea.MouseActionPress {
            // 处理左键点击
            fmt.Printf("点击位置: (%d, %d)\n", msg.X, msg.Y)
        }
        if msg.IsWheel() {
            // 处理滚轮事件
            fmt.Println("滚轮事件")
        }
    }
    return m, nil
}
```

### Cmd 类型

Cmd 是一个 I/O 操作，完成后返回一个消息。

```go
type Cmd func() Msg
```

#### 内置命令

| 命令 | 返回值 | 说明 |
|--------|---------|------|
| `Quit()` | `Msg` | 退出命令 |
| `Suspend()` | `Msg` | 暂停命令 |
| `Interrupt()` | `Msg` | 中断命令 |
| `ClearScreen()` | `Msg` | 清除屏幕命令 |
| `EnterAltScreen()` | `Msg` | 进入备用屏幕命令 |
| `ExitAltScreen()` | `Msg` | 退出备用屏幕命令 |
| `EnableMouseCellMotion()` | `Msg` | 启用鼠标单元格运动命令 |
| `EnableMouseAllMotion()` | `Msg` | 启用鼠标所有运动命令 |
| `DisableMouse()` | `Msg` | 禁用鼠标命令 |
| `ShowCursor()` | `Msg` | 显示光标命令 |
| `HideCursor()` | `Msg` | 隐藏光标命令 |
| `EnableBracketedPaste()` | `Msg` | 启用括号粘贴命令 |
| `DisableBracketedPaste()` | `Msg` | 禁用括号粘贴命令 |
| `EnableReportFocus()` | `Msg` | 启用焦点报告命令 |
| `DisableReportFocus()` | `Msg` | 禁用焦点报告命令 |
| `SetWindowTitle(title)` | `Msg` | 设置窗口标题命令 |

#### 批量命令

| 命令 | 参数 | 返回值 | 说明 |
|--------|--------|---------|------|
| `Batch(cmds...)` | `...Cmd` | `Cmd` | 并发执行多个命令，无顺序保证 |
| `Sequence(cmds...)` | `...Cmd` | `Cmd` | 顺序执行多个命令 |

#### 定时命令

| 命令 | 参数 | 返回值 | 说明 |
|--------|--------|---------|------|
| `Every(duration, fn)` | `time.Duration, func(time.Time) Msg` | `Cmd` | 定时器命令，按系统时钟触发 |
| `Tick(duration, fn)` | `time.Duration, func(time.Time) Msg` | `Cmd` | 单次定时命令 |

#### 执行命令

| 命令 | 参数 | 返回值 | 说明 |
|--------|--------|---------|------|
| `Exec(cmd, fn)` | `ExecCommand, ExecCallback` | `Cmd` | 执行外部命令 |
| `ExecProcess(c, fn)` | `*exec.Cmd, ExecCallback` | `Cmd` | 执行进程命令 |

#### 使用示例

```go
// 批量命令
func (m model) Init() tea.Cmd {
    return tea.Batch(
        tea.EnterAltScreen(),
        tea.EnableMouseCellMotion(),
    )
}

// 定时命令
func tickEvery() tea.Cmd {
    return tea.Every(time.Second, func(t time.Time) tea.Msg {
        return TickMsg(t)
    })
}

// 执行命令
cmd := exec.Command("vim", "file.txt")
execCmd := tea.ExecProcess(cmd, func(err error) tea.Msg {
    return ExecFinishedMsg{err: err}
})
```

## ProgramOption 类型

ProgramOption 用于配置程序。

```go
type ProgramOption func(*Program)
```

#### 选项函数

| 选项 | 参数 | 说明 |
|--------|--------|------|
| `WithContext(ctx)` | `context.Context` | 设置运行上下文 |
| `WithOutput(w)` | `io.Writer` | 设置输出目标 |
| `WithInput(r)` | `io.Reader` | 设置输入源 |
| `WithInputTTY()` | - | 打开新的 TTY 输入 |
| `WithEnvironment(env)` | `[]string` | 设置环境变量 |
| `WithoutSignalHandler()` | - | 禁用信号处理器 |
| `WithoutCatchPanics()` | - | 禁用 panic 捕获 |
| `WithoutSignals()` | - | 忽略 OS 信号 |
| `WithAltScreen()` | - | 启用备用屏幕 |
| `WithMouseCellMotion()` | - | 启用鼠标单元格运动 |
| `WithMouseAllMotion()` | - | 启用鼠标所有运动 |
| `WithFPS(fps)` | `int` | 设置帧率 |
| `WithANSICompressor()` | - | 启用 ANSI 压缩 |
| `WithFilter(fn)` | `func(Model, Msg) Msg` | 设置消息过滤器 |
| `WithRenderer(r)` | `renderer` | 设置自定义渲染器 |

#### 使用示例

```go
p := tea.NewProgram(initialModel(),
    tea.WithAltScreen(),
    tea.WithMouseCellMotion(),
    tea.WithFPS(60),
    tea.WithANSICompressor(),
)
```

## 错误类型

### 标准错误

| 错误 | 说明 |
|--------|------|
| `ErrProgramPanic` | 程序经历了 panic |
| `ErrProgramKilled` | 程序被终止 |
| `ErrInterrupted` | 程序被中断 |

#### 使用示例

```go
finalModel, err := p.Run()
if err != nil {
    if errors.Is(err, tea.ErrProgramPanic) {
        log.Println("程序发生 panic")
    } else if errors.Is(err, tea.ErrProgramKilled) {
        log.Println("程序被终止")
    } else if errors.Is(err, tea.ErrInterrupted) {
        log.Println("程序被中断")
    }
}
```

## 总结

Bubble Tea CN 提供了简洁而强大的 API：

1. **清晰的接口**: Model、Renderer 等核心接口定义明确
2. **丰富的消息类型**: 支持键盘、鼠标、窗口等多种消息
3. **灵活的命令**: 支持批量、序列、定时等多种命令
4. **可配置的选项**: 提供丰富的程序配置选项
5. **完整的错误处理**: 定义了清晰的错误类型

这种 API 设计使得构建复杂的终端用户界面变得简单而愉悦。
