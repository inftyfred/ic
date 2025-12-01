#!/bin/bash

# VCS 自动编译脚本
# 自动检测 src 文件夹中的 .v 文件并编译

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 脚本目录和项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 目录路径
SRC_DIR="$PROJECT_ROOT/src"
TB_DIR="$PROJECT_ROOT/tb"
INCLUDE_DIR="$PROJECT_ROOT/include"
BUILD_DIR="$PROJECT_ROOT/build"
WAVE_DIR="$PROJECT_ROOT/wave"

# 创建必要的目录
mkdir -p "$BUILD_DIR"
mkdir -p "$WAVE_DIR"

# 日志文件
LOG_FILE="$BUILD_DIR/compile.log"
SIMV_PATH="$BUILD_DIR/simv"

# 显示信息函数
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查源文件目录
check_src_directory() {
    if [ ! -d "$SRC_DIR" ]; then
        error "源文件目录不存在: $SRC_DIR"
        return 1
    fi
    
    local v_files=$(find "$SRC_DIR" -name "*.v" -o -name "*.sv" | wc -l)
    if [ "$v_files" -eq 0 ]; then
        warn "在 $SRC_DIR 中未找到 .v 或 .sv 文件"
        return 1
    fi
    
    info "找到 $v_files 个 Verilog/SystemVerilog 文件"
    return 0
}

# 生成文件列表
generate_filelist() {
    local filelist="$BUILD_DIR/filelist.f"
    
    info "生成文件列表: $filelist"
    
    # 清空或创建文件列表
    > "$filelist"
    
    # 添加包含目录
    if [ -d "$INCLUDE_DIR" ]; then
        echo "+incdir+$INCLUDE_DIR" >> "$filelist"
    fi
    echo "+incdir+$SRC_DIR" >> "$filelist"
    
    # 添加测试平台文件（如果存在）
    if [ -d "$TB_DIR" ]; then
        find "$TB_DIR" -name "*.v" -o -name "*.sv" | sort >> "$filelist"
    fi

    # 查找并添加所有 .v 和 .sv 文件
    find "$SRC_DIR" -name "*.v" -o -name "*.sv" | sort >> "$filelist"
    
    
    # 显示文件列表内容
    info "文件列表内容:"
    cat "$filelist" | while read line; do
        echo "  $line"
    done
}

# 执行编译
compile_design() {
    info "开始编译..."
    info "日志文件: $LOG_FILE"
    
    # 检查 VCS 是否可用
    if ! command -v vcs &> /dev/null; then
        error "VCS 未找到，请确保 VCS 已安装并在 PATH 中"
        return 1
    fi
    
    # VCS 编译命令
    vcs -full64 \
        +v2k \
        -sverilog \
        -fsdb \
        +define+FSDB \
        -debug_access+all \
        -f "$BUILD_DIR/filelist.f" \
        -o "$SIMV_PATH" \
        -l "$LOG_FILE" \
		-j8 \
		-timescale=1ns/1ps \
		+plusarg_save		\
		+memcbk				\
        "-LDFLAGS -Wl,--no-as-needed"
    
    local compile_status=$?
    
    if [ $compile_status -eq 0 ]; then
        info "编译成功!"
        info "可执行文件: $SIMV_PATH"
        return 0
    else
        error "编译失败，请检查日志文件: $LOG_FILE"
        return 1
    fi
}

# 显示编译摘要
show_summary() {
    info "=== 编译摘要 ==="
    info "项目根目录: $PROJECT_ROOT"
    info "源文件目录: $SRC_DIR"
    info "编译输出: $BUILD_DIR"
    info "仿真程序: $SIMV_PATH"
    
    if [ -f "$SIMV_PATH" ]; then
        info "编译状态: ${GREEN}成功${NC}"
    else
        info "编译状态: ${RED}失败${NC}"
    fi
}

# 主函数
main() {
    info "VCS 自动编译脚本启动"
    info "项目根目录: $PROJECT_ROOT"
    
    # 检查源文件目录
    if ! check_src_directory; then
        error "源文件检查失败"
        exit 1
    fi
    
    # 生成文件列表
    generate_filelist
    
    # 执行编译
    if compile_design; then
        show_summary
    else
        exit 1
    fi
}

# 运行主函数
main "$@"
