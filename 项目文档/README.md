# Bubble Tea CN 项目文档

## 概述

本文档目录包含 Bubble Tea CN 项目的完整技术文档，涵盖了架构设计、API 接口、开发规范、部署流程、测试策略、版本控制和故障排除等方面的内容。

Bubble Tea CN 是一个基于 [The Elm Architecture](https://guide.elm-lang.org/architecture/) 设计范式的 Go 语言 TUI（终端用户界面）框架，是对 [Charmbracelet/Bubble Tea](https://github.com/charmbracelet/bubbletea) 的中文本地化衍生版本。

## 文档目录

### 架构文档

#### [01-项目架构概述](architecture/01-项目架构概述.md)
- 核心架构模式（MVU）
- 核心组件说明
- 数据流图
- 平台抽象
- 配置选项
- 错误处理
- 性能优化
- 扩展性

#### [02-技术栈说明](architecture/02-技术栈说明.md)
- 编程语言（Go 1.24.2）
- 核心依赖库
- 平台支持
- 终端特性
- 开发工具
- 测试工具
- 性能优化
- 部署环境
- 安全性
- 兼容性

#### [03-模块划分](architecture/03-模块划分.md)
- 核心模块说明
- Program 模块
- Model 模块
- Msg 模块
- Cmd 模块
- Renderer 模块
- Key 模块
- Mouse 模块
- Screen 模块
- Options 模块
- Focus 模块
- Exec 模块
- TTY 模块
- Logging 模块
- Signals 模块
- 模块依赖关系
- 模块交互

### API 文档

#### [01-API接口文档](api/01-API接口文档.md)
- 核心接口
  - Model 接口
  - Renderer 接口
  - ExecCommand 接口
- 核心类型
  - Program 类型
  - Msg 类型
  - KeyMsg 类型
  - MouseMsg 类型
  - Cmd 类型
  - ProgramOption 类型
- 错误类型

#### [02-数据流程文档](api/02-数据流程文档.md)
- 初始化流程
- 运行流程
- 事件处理流程
- 渲染流程
- 命令执行流程
- 输入处理流程
- 终端管理流程
- 窗口大小变化流程
- 焦点管理流程

### 开发文档

#### [01-开发规范](development/01-开发规范.md)
- Go 代码规范
  - 格式化
  - 导入顺序
  - 命名规范
  - 错误处理
  - 并发
  - 注释规范
- 文件组织
- 测试规范
- 命名规范
- 代码审查标准
- 文档编写规范
- 版本控制
- 性能优化
- 安全规范

### 部署文档

#### [01-构建部署流程](deployment/01-构建部署流程.md)
- 环境要求
- 环境配置
- 构建流程
  - 本地构建
  - 使用 Make 构建
  - 使用 Task 构建
- 测试流程
  - 单元测试
  - 集成测试
  - 基准测试
- 代码质量检查
- 部署流程
  - 本地部署
  - Docker 部署
  - 生产部署
- 环境变量配置
- CI/CD 配置
- 监控和日志
- 故障排除

### 测试文档

#### [01-测试策略](testing/01-测试策略.md)
- 测试类型
  - 单元测试
  - 集成测试
  - 系统测试
- 测试工具
  - Go Testing
  - teatest
  - golangci-lint
- 测试覆盖率
- 基准测试
- 并发测试
- Mock 和 Stub
- 测试数据管理
- 测试最佳实践
- 持续集成

### 版本控制文档

#### [01-版本控制策略](version-control/01-版本控制策略.md)
- 分支管理策略
  - 分支类型
  - 分支流程图
- 代码合并流程
  - Pull Request 流程
  - 合并策略
- 版本号命名规则
  - 语义化版本
  - 版本标签
  - 版本发布流程
- 提交信息规范
- 分支保护规则
- 代码审查规范
- 回退策略
- 持续集成

### 故障排除文档

#### [01-常见问题解决方案](troubleshooting/01-常见问题解决方案.md)
- 开发问题
  - 程序无法启动
  - 终端显示异常
  - 程序无响应
  - 内存泄漏
- 测试问题
  - 测试超时
  - 测试覆盖率不足
  - 并发测试失败
- 部署问题
  - 构建失败
  - 运行时错误
  - 性能问题
- 终端问题
  - 终端状态未恢复
  - 鼠标不工作
  - 窗口大小变化未响应
- 性能优化
  - 渲染性能
  - 内存优化
- 调试技巧

## 快速开始

### 安装

```bash
go get github.com/purpose168/bubbletea-cn
```

### 基本使用

```go
package main

import (
    "fmt"
    "github.com/purpose168/bubbletea-cn"
)

type model struct {
    choices []string
    cursor  int
}

func (m model) Init() tea.Cmd {
    return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "up":
            if m.cursor > 0 {
                m.cursor--
            }
        case "down":
            if m.cursor < len(m.choices)-1 {
                m.cursor++
            }
        case "enter", " ":
            return m, tea.Quit
        case "q", "ctrl+c":
            return m, tea.Quit
        }
    }
    return m, nil
}

func (m model) View() string {
    s := "What should we buy at the market?\n\n"
    
    for i, choice := range m.choices {
        cursor := " "
        if m.cursor == i {
            cursor = ">"
        }
        s += fmt.Sprintf("%s %s\n", cursor, choice)
    }
    
    s += "\nPress q to quit.\n"
    return s
}

func main() {
    p := tea.NewProgram(model{
        choices: []string{"Buy carrots", "Buy celery", "Buy kohlrabi"},
    })
    
    if _, err := p.Run(); err != nil {
        fmt.Printf("Alas, there's been an error: %v", err)
    }
}
```

## 核心概念

### MVU 架构

Bubble Tea 采用 **MVU（Model-View-Update）** 架构模式：

- **Model（模型）**: 表示应用程序的状态
- **View（视图）**: 根据模型状态渲染 UI
- **Update（更新）**: 处理消息并更新模型状态

### 消息驱动

所有交互都通过消息传递：

- **Msg**: 任何类型，用于传递信息
- **Cmd**: I/O 操作，完成后返回消息
- **Batch**: 并发执行多个命令
- **Sequence**: 顺序执行多个命令

### 平台支持

Bubble Tea 支持多个平台：

- **Linux**: 完全支持
- **macOS**: 完全支持
- **Windows**: 完全支持
- **BSD**: 部分支持

## 技术栈

- **语言**: Go 1.24.2+
- **核心依赖**:
  - github.com/muesli/cancelreader v0.2.2
  - github.com/purpose168/charm-experimental-packages-cn/term v0.2.1
  - golang.org/x/sys v0.41.0
  - golang.org/x/term v0.31.0

## 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: 添加某个功能'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

- 作者: purpose168
- 邮箱: purpose168@outlook.com
- 项目链接: https://github.com/purpose168/bubbletea-cn

## 相关项目

- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - 原始项目
- [Bubbles CN](https://github.com/purpose168/bubbles-cn) - UI 组件库
- [Lipgloss CN](https://github.com/purpose168/lipgloss-cn) - 样式库

## 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本更新历史。

## 致谢

感谢 [Charmbracelet](https://github.com/charmbracelet) 团队创建了优秀的 Bubble Tea 框架。
