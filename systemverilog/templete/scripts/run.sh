#!/bin/bash

# VCS 仿真运行脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 脚本目录和项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 目录路径
BUILD_DIR="$PROJECT_ROOT/build"
WAVE_DIR="$PROJECT_ROOT/wave"
LOG_DIR="$PROJECT_ROOT/logs"

# 可执行文件路径
SIMV_PATH="$BUILD_DIR/simv"

# 默认参数
DEFAULT_TEST_NAME="basic_test"
DEFAULT_WAVE_TYPE="fsdb"
DEFAULT_TIMEOUT="1000000"

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

debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# 显示使用说明
usage() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -t, --test TESTNAME     测试案例名称 (默认: $DEFAULT_TEST_NAME)"
    echo "  -w, --wave WAVETYPE     波形类型 fsdb|vcd (默认: $DEFAULT_WAVE_TYPE)"
    echo "  -o, --timeout TIMEOUT   仿真超时时间 (默认: $DEFAULT_TIMEOUT)"
    echo "  -l, --log LOGFILE       日志文件名"
    echo "  -g, --gui               启用 GUI 模式 (DVE)"
    echo "  -h, --help              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -t smoke_test -w fsdb"
    echo "  $0 --test functional_test --timeout 500000 --gui"
}

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--test)
                TEST_NAME="$2"
                shift 2
                ;;
            -w|--wave)
                WAVE_TYPE="$2"
                shift 2
                ;;
            -o|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            -g|--gui)
                GUI_MODE=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "未知参数: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # 设置默认值
    TEST_NAME=${TEST_NAME:-$DEFAULT_TEST_NAME}
    WAVE_TYPE=${WAVE_TYPE:-$DEFAULT_WAVE_TYPE}
    TIMEOUT=${TIMEOUT:-$DEFAULT_TIMEOUT}
    LOG_FILE=${LOG_FILE:-"$LOG_DIR/simulation_${TEST_NAME}.log"}
}

# 检查前置条件
check_prerequisites() {
    # 检查仿真程序是否存在
    if [ ! -f "$SIMV_PATH" ]; then
        error "仿真程序不存在: $SIMV_PATH"
        error "请先运行编译脚本: ./scripts/compile.sh"
        return 1
    fi
    
    # 检查是否可执行
    if [ ! -x "$SIMV_PATH" ]; then
        error "仿真程序不可执行: $SIMV_PATH"
        return 1
    fi
    
    # 创建日志目录
    mkdir -p "$LOG_DIR"
    mkdir -p "$WAVE_DIR"
    
    return 0
}

# 生成运行时参数
generate_run_options() {
    local options=""
    
    # 基本参数
    options+="+TESTNAME=$TEST_NAME"
    options+=" +TIMEOUT=$TIMEOUT"
    
    # 波形参数
    case $WAVE_TYPE in
        fsdb)
            options+=" +FSDB=1"
            options+=" +WAVE_FILE=$WAVE_DIR/wave_${TEST_NAME}.fsdb"
            ;;
        vcd)
            options+=" +VCD=1"
            options+=" +WAVE_FILE=$WAVE_DIR/wave_${TEST_NAME}.vcd"
            ;;
        *)
            warn "不支持的波形类型: $WAVE_TYPE，使用默认 fsdb"
            options+=" +FSDB=1"
            options+=" +WAVE_FILE=$WAVE_DIR/wave_${TEST_NAME}.fsdb"
            ;;
    esac
    
    # GUI 模式
#    if [ "$GUI_MODE" -eq 1 ]; then
#        options+=" -gui"
#    fi
    
    echo "$options"
}

# 运行仿真
run_simulation() {
    local run_options=$(generate_run_options)
    
    info "开始仿真..."
    info "测试案例: $TEST_NAME"
    info "波形类型: $WAVE_TYPE"
    info "日志文件: $LOG_FILE"
    info "超时设置: $TIMEOUT"
    
#    if [ "$GUI_MODE" -eq 1 ]; then
#        info "GUI 模式: 启用"
#    fi
    
    debug "运行命令: $SIMV_PATH $run_options -l $LOG_FILE"
    
    # 执行仿真
    cd "$BUILD_DIR" && "$SIMV_PATH" $run_options -l "$LOG_FILE"
    
    local sim_status=$?
    
    return $sim_status
}

# 检查仿真结果
check_results() {
    local log_file="$1"
    
    info "检查仿真结果..."
    
    if [ ! -f "$log_file" ]; then
        warn "日志文件不存在: $log_file"
        return 1
    fi
    
    # 检查常见的成功模式
    if grep -q "TEST PASSED" "$log_file" || \
       grep -q "Simulation Finished Successfully" "$log_file" || \
       grep -q "SUCCESS" "$log_file"; then
        info "仿真结果: ${GREEN}通过${NC}"
        return 0
    fi
    
    # 检查常见的失败模式
    if grep -q "TEST FAILED" "$log_file" || \
       grep -q "ERROR" "$log_file" || \
       grep -q "FATAL" "$log_file"; then
        error "仿真结果: ${RED}失败${NC}"
        return 1
    fi
    
    #warn "无法确定仿真结果，请检查日志文件"
	info "运行结束"
    return 0
}

# 显示仿真摘要
show_simulation_summary() {
    info "=== 仿真摘要 ==="
    info "测试案例: $TEST_NAME"
    info "日志文件: $LOG_FILE"
    info "波形文件: $WAVE_DIR/wave_${TEST_NAME}.$WAVE_TYPE"
    
    if [ -f "$LOG_FILE" ]; then
        # 显示仿真时间
        local sim_time=$(grep -o "Simulation Time:.*" "$LOG_FILE" | head -1)
        if [ -n "$sim_time" ]; then
            info "$sim_time"
        fi
        
        check_results "$LOG_FILE"
    fi
}

# 主函数
main() {
    info "VCS 仿真运行脚本启动"
    
    # 解析参数
    parse_arguments "$@"
    
    # 检查前置条件
    if ! check_prerequisites; then
        exit 1
    fi
    
    # 运行仿真
    if run_simulation; then
        show_simulation_summary
    else
        error "仿真运行失败"
        exit 1
    fi
}

# 运行主函数
main "$@"
