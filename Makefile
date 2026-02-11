# Bubble Tea 项目 Makefile
# 功能完善的构建脚本，支持项目的主要开发流程

# 定义变量
GO := go
GOPATH := $(shell $(GO) env GOPATH)
GOBIN := $(GOPATH)/bin

# 项目名称
PROJECT := bubbletea-cn

# 源代码目录
SRC_DIR := .

# 示例目录
EXAMPLES_DIR := examples

# 教程目录
TUTORIALS_DIR := tutorials

# 测试覆盖报告目录
COVERAGE_DIR := coverage

# 构建输出目录
BUILD_DIR := build

# 定义目标
.PHONY: all build test clean install deploy init tidy format lint examples tutorials help

# 默认目标
all: build test

# 构建项目
# 运行 `make build` 来构建项目
build:
	@echo "=== 构建项目 ==="
	@$(GO) build -v .

# 运行测试
# 运行 `make test` 来执行核心包测试
# 运行 `make test TEST=./path/to/test` 来执行特定测试
TEST ?= .
test:
	@echo "=== 运行测试 ==="
	@$(GO) test -v $(TEST)

# 生成测试覆盖报告
# 运行 `make coverage` 来生成测试覆盖报告
coverage:
	@echo "=== 生成测试覆盖报告 ==="
	@mkdir -p $(COVERAGE_DIR)
	@$(GO) test -v -coverprofile=$(COVERAGE_DIR)/coverage.out ./...
	@$(GO) tool cover -html=$(COVERAGE_DIR)/coverage.out -o $(COVERAGE_DIR)/coverage.html
	@echo "测试覆盖报告已生成: $(COVERAGE_DIR)/coverage.html"

# 清理构建产物
# 运行 `make clean` 来清理构建产物和临时文件
clean:
	@echo "=== 清理构建产物 ==="
	@$(GO) clean ./...
	@rm -rf $(BUILD_DIR) $(COVERAGE_DIR)
	@find . -name "*.test" -type f -delete

# 安装项目
# 运行 `make install` 来安装项目到 GOPATH
install:
	@echo "=== 安装项目 ==="
	@$(GO) install -v ./...

# 初始化模块
# 运行 `make init` 来初始化 Go 模块
init:
	@echo "=== 初始化模块 ==="
	@$(GO) mod init github.com/charmbracelet/bubbletea
	@$(MAKE) tidy

# 重新初始化模块（修复依赖问题）
# 运行 `make reinit` 来重新初始化模块并修复依赖
reinit:
	@echo "=== 重新初始化模块 ==="
	@if [ -f go.mod ]; then rm go.mod; fi
	@if [ -f go.sum ]; then rm go.sum; fi
	@$(MAKE) init

# 整理依赖
# 运行 `make tidy` 来整理和更新依赖

tidy:
	@echo "=== 整理依赖 ==="
	@$(GO) mod tidy

# 格式化代码
# 运行 `make format` 来格式化代码
format:
	@echo "=== 格式化代码 ==="
	@$(GO) fmt ./...

# 运行 lint 检查
# 运行 `make lint` 来执行代码风格检查
lint:
	@echo "=== 运行 lint 检查 ==="
	@if ! command -v golangci-lint &> /dev/null; then \
		echo "安装 golangci-lint..."; \
		$(GO) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
	fi
	@golangci-lint run

# 构建示例
# 运行 `make examples` 来构建所有示例

examples:
	@echo "=== 构建示例 ==="
	@if [ -d "$(EXAMPLES_DIR)" ]; then \
		for example in $(EXAMPLES_DIR)/*; do \
			if [ -d "$$example" ]; then \
				echo "构建示例: $$example"; \
				(cd "$$example" && $(GO) build -v .); \
			fi; \
		done; \
	else \
		echo "示例目录不存在: $(EXAMPLES_DIR)"; \
	fi

# 构建教程
# 运行 `make tutorials` 来构建所有教程

tutorials:
	@echo "=== 构建教程 ==="
	@if [ -d "$(TUTORIALS_DIR)" ]; then \
		for tutorial in $(TUTORIALS_DIR)/*; do \
			if [ -d "$$tutorial" ]; then \
				echo "构建教程: $$tutorial"; \
				(cd "$$tutorial" && $(GO) build -v .); \
			fi; \
		done; \
	else \
		echo "教程目录不存在: $(TUTORIALS_DIR)"; \
	fi

# 显示帮助信息
# 运行 `make help` 来显示此帮助信息
help:
	@echo "=== Bubble Tea 项目 Makefile 帮助 ==="
	@echo "可用目标:"
	@echo "  make all          - 构建并测试项目（默认目标）"
	@echo "  make build        - 构建项目"
	@echo "  make test         - 运行测试（可指定 TEST=./path/to/test）"
	@echo "  make coverage     - 生成测试覆盖报告"
	@echo "  make clean        - 清理构建产物"
	@echo "  make install      - 安装项目到 GOPATH"
	@echo "  make init         - 初始化 Go 模块"
	@echo "  make reinit       - 重新初始化模块并修复依赖"
	@echo "  make tidy         - 整理和更新依赖"
	@echo "  make format       - 格式化代码"
	@echo "  make lint         - 运行 lint 检查"
	@echo "  make examples     - 构建所有示例"
	@echo "  make tutorials    - 构建所有教程"
	@echo "  make help         - 显示此帮助信息"
	@echo ""
	@echo "使用示例:"
	@echo "  make build        # 构建项目"
	@echo "  make test         # 运行所有测试"
	@echo "  make test TEST=./key_test.go # 运行特定测试"
	@echo "  make clean        # 清理构建产物"
	@echo "  make format       # 格式化代码"
