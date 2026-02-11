# Bubble Tea

<p>
    <picture>
      <source media="(prefers-color-scheme: light)" srcset="https://stuff.charm.sh/bubbletea/bubble-tea-v2-light.png" width="308">
      <source media="(prefers-color-scheme: dark)" srcset="https://stuff.charm.sh/bubbletea/bubble-tea-v2-dark.png" width="312">
      <img src="https://stuff.charm.sh/bubbletea/bubble-tea-v2-light.png" width="308" />
    </picture>
    <br>
    <a href="https://github.com/purpose168/bubbletea-cn/releases"><img src="https://img.shields.io/github/release/charmbracelet/bubbletea.svg" alt="最新版本"></a>
    <a href="https://pkg.go.dev/github.com/charmbracelet/bubbletea?tab=doc"><img src="https://godoc.org/github.com/charmbracelet/bubbletea?status.svg" alt="GoDoc"></a>
    <a href="https://github.com/purpose168/bubbletea-cn/actions"><img src="https://github.com/purpose168/bubbletea-cn/actions/workflows/build.yml/badge.svg?branch=main" alt="构建状态"></a>
</p>

构建终端应用的有趣、实用且有状态的方法。一个基于 [The Elm Architecture][elm] 的 Go 框架。Bubble Tea 非常适合简单和复杂的终端应用程序，无论是内联、全屏窗口还是两者的混合。

<p>
    <img src="https://stuff.charm.sh/bubbletea/bubbletea-example.gif" width="100%" alt="Bubble Tea 示例">
</p>

Bubble Tea 已在生产环境中使用，并包含了我们在开发过程中添加的许多功能和性能优化。其中包括基于帧率的渲染器、鼠标支持、焦点报告等。

要开始使用，请查看下面的教程、[示例][examples]、[文档][docs]、[视频教程][youtube] 和一些常见的 [资源](#我们与-bubble-tea-一起使用的库)。

[youtube]: https://charm.sh/yt

## 顺便说一下

请务必查看 [Bubbles][bubbles]，这是一个为 Bubble Tea 提供常见 UI 组件的库。

<p>
    <a href="https://github.com/charmbracelet/bubbles"><img src="https://stuff.charm.sh/bubbles/bubbles-badge.png" width="174" alt="Bubbles 徽章"></a>&nbsp;&nbsp;
    <a href="https://github.com/charmbracelet/bubbles"><img src="https://stuff.charm.sh/bubbles-examples/textinput.gif" width="400" alt="来自 Bubbles 的文本输入示例"></a>
</p>

---

## 教程

Bubble Tea 基于 [The Elm Architecture][elm] 的函数式设计范式，这种范式恰好与 Go 语言配合得很好。这是一种令人愉悦的应用程序构建方式。

本教程假设你已经具备 Go 语言的工作知识。

顺便说一下，本程序的未注释源代码可在 [GitHub][tut-source] 上找到。

[elm]: https://guide.elm-lang.org/architecture/
[tut-source]: https://github.com/purpose168/bubbletea-cn/tree/main/tutorials/basics

### 好了！让我们开始吧。

在本教程中，我们将创建一个购物清单应用。

首先，我们将定义包并导入一些库。我们唯一的外部导入是 Bubble Tea 库，我们将其简称为 `tea`。

```go
package main

// 这些导入将在教程的后续部分使用。如果你现在保存文件，
// Go 可能会抱怨它们未使用，但这没关系。
// 你可能还需要运行 `go mod tidy` 来下载 bubbletea 及其依赖项。
import (
    "fmt"
    "os"

    tea "github.com/purpose168/bubbletea-cn"
)
```

Bubble Tea 程序由一个描述应用程序状态的 **模型** 和该模型上的三个简单方法组成：

- **Init**：一个返回应用程序初始命令的函数。
- **Update**：一个处理传入事件并相应更新模型的函数。
- **View**：一个基于模型中的数据渲染 UI 的函数。

### 模型

让我们首先定义我们的模型，它将存储应用程序的状态。它可以是任何类型，但 `struct` 通常是最合理的选择。

```go
// model 定义了应用程序的状态
type model struct {
    choices  []string           // 待办事项列表中的项目
    cursor   int                // 光标指向的待办事项索引
    selected map[int]struct{}   // 已选择的待办事项
}
```

### 初始化

接下来，我们将定义应用程序的初始状态。在这种情况下，我们定义一个函数来返回我们的初始模型，但我们也可以在其他地方将初始模型定义为变量。

```go
// initialModel 返回应用程序的初始模型
func initialModel() model {
	return model{
		// 我们的待办事项列表是一个购物清单
		choices:  []string{"Buy carrots", "Buy celery", "Buy kohlrabi"},

		// 一个表示哪些选项被选中的映射。我们将映射用作数学集合。
		// 键引用上面 `choices` 切片的索引。
		selected: make(map[int]struct{}),
	}
}
```

接下来，我们定义 `Init` 方法。`Init` 可以返回一个 `Cmd`，用于执行一些初始 I/O 操作。现在，我们不需要执行任何 I/O 操作，所以对于命令，我们只返回 `nil`，这表示"无命令"。

```go
// Init 返回应用程序的初始命令
func (m model) Init() tea.Cmd {
    // 只需返回 `nil`，这表示"现在不需要 I/O 操作"。
    return nil
}
```

### Update 方法

接下来是更新方法。当"事情发生"时，会调用更新函数。它的任务是查看发生了什么，并返回一个更新后的模型作为响应。它还可以返回一个 `Cmd` 来使更多事情发生，但现在不用担心这部分。

在我们的例子中，当用户按下向下箭头时，`Update` 的任务是注意到按下了向下箭头，并相应地移动光标（或不移动）。

"发生的事情"以 `Msg` 的形式出现，它可以是任何类型。消息是某些 I/O 操作的结果，例如按键、计时器滴答声或服务器的响应。

我们通常使用类型开关来确定我们收到的 `Msg` 类型，但你也可以使用类型断言。

现在，我们只处理 `tea.KeyMsg` 消息，当按键时，这些消息会自动发送到更新函数。

```go
// Update 处理消息并更新模型状态
func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {

    // 是按键消息吗？
    case tea.KeyMsg:

        // 很酷，实际按下的是什么键？
        switch msg.String() {

        // 这些键应该退出程序。
        case "ctrl+c", "q":
            return m, tea.Quit

        // "up" 和 "k" 键向上移动光标
        case "up", "k":
            if m.cursor > 0 {
                m.cursor--
            }

        // "down" 和 "j" 键向下移动光标
        case "down", "j":
            if m.cursor < len(m.choices)-1 {
                m.cursor++
            }

        // "enter" 键和空格键（字面意义上的空格）切换
        // 光标指向的项目的选择状态。
        case "enter", " ":
            _, ok := m.selected[m.cursor]
            if ok {
                delete(m.selected, m.cursor)
            } else {
                m.selected[m.cursor] = struct{}{}
            }
        }
    }

    // 将更新后的模型返回给 Bubble Tea 运行时进行处理。
    // 注意，我们没有返回命令。
    return m, nil
}
```

你可能已经注意到，上面的 <kbd>ctrl+c</kbd> 和 <kbd>q</kbd> 返回带有模型的 `tea.Quit` 命令。这是一个特殊命令，指示 Bubble Tea 运行时退出程序。

### View 方法

最后，是时候渲染我们的 UI 了。在所有方法中，视图是最简单的。我们查看当前状态下的模型，并使用它返回一个 `string`。这个字符串就是我们的 UI！

因为视图描述了应用程序的整个 UI，所以你不必担心重绘逻辑之类的事情。Bubble Tea 会为你处理这些。

```go
// View 根据模型状态渲染 UI
func (m model) View() string {
    // 头部
    s := "What should we buy at the market?\n\n"

    // 遍历我们的选项
    for i, choice := range m.choices {

        // 光标是否指向这个选项？
        cursor := " " // 无光标
        if m.cursor == i {
            cursor = ">" // 有光标！
        }

        // 这个选项是否被选中？
        checked := " " // 未选中
        if _, ok := m.selected[i]; ok {
            checked = "x" // 已选中！
        }

        // 渲染行
        s += fmt.Sprintf("%s [%s] %s\n", cursor, checked, choice)
    }

    // 底部
    s += "\nPress q to quit.\n"

    // 发送 UI 进行渲染
    return s
}
```

### 全部整合

最后一步是简单地运行我们的程序。我们将初始模型传递给 `tea.NewProgram` 并让它运行：

```go
// main 是应用程序的入口点
func main() {
    p := tea.NewProgram(initialModel())
    if _, err := p.Run(); err != nil {
        fmt.Printf("Alas, there's been an error: %v", err)
        os.Exit(1)
    }
}
```

## 接下来做什么？

本教程涵盖了构建交互式终端 UI 的基础知识，但在现实世界中，你还需要执行 I/O 操作。要了解这方面的内容，请查看 [命令教程][cmd]。它非常简单。

还有几个 [Bubble Tea 示例][examples] 可供参考，当然，还有 [Go 文档][docs]。

[cmd]: https://github.com/purpose168/bubbletea-cn/tree/main/tutorials/commands/
[examples]: https://github.com/purpose168/bubbletea-cn/tree/main/examples
[docs]: https://pkg.go.dev/github.com/charmbracelet/bubbletea?tab=doc

## 调试

### 使用 Delve 调试

由于 Bubble Tea 应用程序会控制 stdin 和 stdout，你需要以无头模式运行 delve，然后连接到它：

```bash
# 启动调试器
$ dlv debug --headless --api-version=2 --listen=127.0.0.1:43000 .
API server listening at: 127.0.0.1:43000

# 从另一个终端连接到它
$ dlv connect 127.0.0.1:43000
```

如果你没有明确提供 `--listen` 标志，使用的端口会在每次运行时变化，因此传入此标志可以使调试器更易于从脚本或你选择的 IDE 中使用。

此外，我们传入 `--api-version=2`，因为 delve 默认使用版本 1 以保持向后兼容性。然而，delve 建议对所有新开发使用版本 2，并且一些客户端可能不再与版本 1 兼容。有关更多信息，请参阅 [Delve 文档](https://github.com/go-delve/delve/tree/master/Documentation/api)。

### 日志记录

你不能真正使用 Bubble Tea 向 stdout 记录日志，因为你的 TUI 正忙于占用它！但是，你可以通过在启动 Bubble Tea 程序之前包含以下内容来将日志记录到文件：

```go
// 如果设置了 DEBUG 环境变量，则启用日志记录
if len(os.Getenv("DEBUG")) > 0 {
	f, err := tea.LogToFile("debug.log", "debug")
	if err != nil {
		fmt.Println("fatal:", err)
		os.Exit(1)
	}
	defer f.Close()
}
```

要实时查看正在记录的内容，请在另一个窗口中运行 `tail -f debug.log`，同时运行你的程序。

## 我们与 Bubble Tea 一起使用的库

- [Bubbles][bubbles]：常见的 Bubble Tea 组件，如文本输入、视口、加载指示器等
- [Lip Gloss][lipgloss]：终端应用程序的样式、格式和布局工具
- [Harmonica][harmonica]：用于平滑、自然运动的弹簧动画库
- [BubbleZone][bubblezone]：Bubble Tea 组件的简单鼠标事件跟踪
- [ntcharts][ntcharts]：为 Bubble Tea 和 [Lip Gloss][lipgloss] 构建的终端图表库

[bubbles]: https://github.com/charmbracelet/bubbles
[lipgloss]: https://github.com/charmbracelet/lipgloss
[harmonica]: https://github.com/charmbracelet/harmonica
[bubblezone]: https://github.com/lrstanley/bubblezone
[ntcharts]: https://github.com/NimbleMarkets/ntcharts

## 实际应用中的 Bubble Tea

有超过 [10,000 个应用程序](https://github.com/purpose168/bubbletea-cn/network/dependents) 是使用 Bubble Tea 构建的！以下是其中的一部分。

### 员工推荐

- [chezmoi](https://github.com/twpayne/chezmoi)：跨多台机器安全管理你的点文件
- [circumflex](https://github.com/bensadeh/circumflex)：在终端中阅读 Hacker News
- [gh-dash](https://www.github.com/dlvhdr/gh-dash)：用于 PR 和问题的 GitHub CLI 扩展
- [Tetrigo](https://github.com/Broderick-Westrope/tetrigo)：终端中的俄罗斯方块
- [Signls](https://github.com/emprcl/signls)：专为作曲和现场表演设计的生成式 MIDI  sequencer
- [Superfile](https://github.com/yorukot/superfile)：超级文件管理器

### 行业应用

- Microsoft Azure – [Aztify](https://github.com/Azure/aztfy)：将 Microsoft Azure 资源纳入 Terraform 管理
- Daytona – [Daytona](https://github.com/daytonaio/daytona)：开源开发环境管理器
- Cockroach Labs – [CockroachDB](https://github.com/cockroachdb/cockroach)：云原生、高可用性分布式 SQL 数据库
- Truffle Security Co. – [Trufflehog](https://github.com/trufflesecurity/trufflehog)：查找泄露的凭据
- NVIDIA – [container-canary](https://github.com/NVIDIA/container-canary)：容器验证器
- AWS – [eks-node-viewer](https://github.com/awslabs/eks-node-viewer)：用于可视化 EKS 集群中动态节点使用情况的工具
- MinIO – [mc](https://github.com/minio/mc)：官方 [MinIO](https://min.io) 客户端
- Ubuntu – [Authd](https://github.com/ubuntu/authd)：用于基于云的身份提供商的身份验证守护程序

### Charm 相关项目

- [Glow](https://github.com/charmbracelet/glow)：Markdown 阅读器、浏览器和在线 Markdown 存储
- [Huh?](https://github.com/charmbracelet/huh)：交互式提示和表单工具包
- [Mods](https://github.com/charmbracelet/mods)：CLI 上的 AI，为管道构建
- [Wishlist](https://github.com/charmbracelet/wishlist)：SSH 目录（和堡垒机！）

### 还有更多

要了解更多使用 Bubble Tea 构建的应用程序，请查看 [Charm & Friends][community]。你用 Bubble Tea 制作了很酷的东西并想分享吗？欢迎提交 [PR][community]！

## 贡献

请参阅 [contributing][contribute]。

[contribute]: https://github.com/purpose168/bubbletea-cn/contribute

## 反馈

我们很想听听你对这个项目的想法。随时给我们留言！

- [Twitter](https://twitter.com/charmcli)
- [联邦宇宙](https://mastodon.social/@charmcli)
- [Discord](https://charm.sh/chat)

## 致谢

Bubble Tea 基于 Evan Czaplicki 等人的 [The Elm Architecture][elm] 范式和 TJ Holowaychuk 的优秀 [go-tea][gotea]。它的灵感来自于过去许多伟大的 [_Zeichenorientierte Benutzerschnittstellen_][zb]（字符导向用户界面）。

[elm]: https://guide.elm-lang.org/architecture/
[gotea]: https://github.com/tj/go-tea
[zb]: https://de.wikipedia.org/wiki/Zeichenorientierte_Benutzerschnittstelle
[community]: https://github.com/charm-and-friends/charm-in-the-wild

## 许可证

[MIT](https://github.com/purpose168/bubbletea-cn/raw/main/LICENSE)

