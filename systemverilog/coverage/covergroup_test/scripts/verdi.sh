#!/bin/bash

# Verdi启动脚本 - 通用版
# 自动发现fsdb文件并从filelist.f读取源文件列表
# 脚本位于scripts目录，build目录在同一级

# 额外启动参数（可通过环境变量 ARGS 或命令行参数 ARGS=... 传递）
EXTRA_ARGS=""
# 重载模式标志
RELOAD_MODE=0

# 设置目录路径（相对于脚本位置）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
FILELIST="$BUILD_DIR/filelist.f"

# 检查目录和文件是否存在
check_prerequisites() {
    if [ ! -d "$BUILD_DIR" ]; then
        echo "错误: 目录不存在 $BUILD_DIR"
        exit 1
    fi
    
    if [ ! -f "$FILELIST" ]; then
        echo "错误: 找不到filelist文件 $FILELIST"
        echo "请确保已经生成了filelist.f"
        exit 1
    fi
}

# 自动发现fsdb文件
find_fsdb_file() {
    local fsdb_files=()
    
    # 查找所有.fsdb文件
    while IFS= read -r -d '' file; do
        fsdb_files+=("$file")
    done < <(find "$BUILD_DIR" -name "*.fsdb" -type f -print0)
    
    if [ ${#fsdb_files[@]} -eq 0 ]; then
        echo "错误: 在 $BUILD_DIR 中找不到任何.fsdb文件"
        exit 1
    fi
    
    # 如果有多个fsdb文件，让用户选择
    if [ ${#fsdb_files[@]} -gt 1 ]; then
        echo "发现多个FSDB文件:"
        for i in "${!fsdb_files[@]}"; do
            echo "  $((i+1))) ${fsdb_files[i]#$BUILD_DIR/}"
        done
        echo -n "请选择要加载的FSDB文件 (1-${#fsdb_files[@]}): "
        read -r choice
        
        if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#fsdb_files[@]} ]; then
            echo "无效选择，使用第一个文件"
            choice=1
        fi
        
        FSDB_FILE="${fsdb_files[$((choice-1))]}"
    else
        FSDB_FILE="${fsdb_files[0]}"
    fi
    
    echo "使用FSDB文件: ${FSDB_FILE#$BUILD_DIR/}"
}

# 自动发现ses文件（用于重载模式）
find_ses_file() {
    local ses_files=()
    local VERDI_LOG_DIR="$PROJECT_ROOT/verdiLog"

    # 检查verdiLog目录是否存在
    if [ ! -d "$VERDI_LOG_DIR" ]; then
        echo "错误: 目录不存在 $VERDI_LOG_DIR"
        exit 1
    fi

    # 查找所有.ses文件
    while IFS= read -r -d '' file; do
        ses_files+=("$file")
    done < <(find "$VERDI_LOG_DIR" -name "*.ses" -type f -print0)

    if [ ${#ses_files[@]} -eq 0 ]; then
        echo "错误: 在 $VERDI_LOG_DIR 中找不到任何.ses文件"
        exit 1
    fi

    # 如果有多个ses文件，让用户选择
    if [ ${#ses_files[@]} -gt 1 ]; then
        echo "发现多个SES文件:"
        for i in "${!ses_files[@]}"; do
            echo "  $((i+1))) ${ses_files[i]#$VERDI_LOG_DIR/}"
        done
        echo -n "请选择要加载的SES文件 (1-${#ses_files[@]}): "
        read -r choice

        if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#ses_files[@]} ]; then
            echo "无效选择，使用第一个文件"
            choice=1
        fi

        SES_FILE="${ses_files[$((choice-1))]}"
    else
        SES_FILE="${ses_files[0]}"
    fi

    echo "使用SES文件: ${SES_FILE#$VERDI_LOG_DIR/}"
}

# 从filelist.f读取源文件
read_source_files() {
    SRC_FILES=()
    
    if [ ! -f "$FILELIST" ]; then
        echo "错误: filelist文件不存在 $FILELIST"
        exit 1
    fi
    
    # 读取filelist.f，跳过空行和注释
    while IFS= read -r line; do
        # 移除前后空白字符
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # 跳过空行和注释行（以#或//开头）
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# || "$line" =~ ^[[:space:]]*// ]]; then
            continue
        fi
        
        # 移除可能的选项标志（如-v, -y等）
        if [[ "$line" =~ ^- ]]; then
            continue
        fi
        
        # 检查文件是否存在（相对于项目根目录）
        if [[ "$line" == /* ]]; then
            # 绝对路径
            if [ -f "$line" ]; then
                SRC_FILES+=("$line")
            else
                echo "警告: 文件不存在，已跳过: $line"
            fi
        else
            # 相对路径 - 相对于filelist.f所在目录或项目根目录
            if [ -f "$BUILD_DIR/$line" ]; then
                SRC_FILES+=("$BUILD_DIR/$line")
            elif [ -f "$PROJECT_ROOT/$line" ]; then
                SRC_FILES+=("$PROJECT_ROOT/$line")
            else
                echo "警告: 文件不存在，已跳过: $line"
            fi
        fi
    done < "$FILELIST"
    
    if [ ${#SRC_FILES[@]} -eq 0 ]; then
        echo "错误: 在filelist中找不到任何有效的源文件"
        exit 1
    fi
}

# 显示使用说明
usage() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -r, --reload       重载模式：从verdiLog目录加载.ses会话文件"
    echo "  ARGS=\"...\"        额外参数传递给Verdi"
    echo "环境变量:"
    echo "  ARGS              额外参数（如果命令行未指定）"
    echo ""
    echo "示例:"
    echo "  $0                     # 正常启动，加载fsdb文件"
    echo "  $0 -r                  # 重载模式，加载.ses会话文件"
    echo "  $0 ARGS=\"-nologo\"     # 传递额外参数给Verdi"
    echo "  $0 -r ARGS=\"-nologo\"  # 重载模式并传递额外参数"
}

# 主函数
main() {
    echo "=========================================="
    echo "启动Verdi调试环境 - 通用版"
    echo "=========================================="
    echo "项目根目录: $PROJECT_ROOT"

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--reload)
                RELOAD_MODE=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            ARGS=*)
                EXTRA_ARGS="${1#ARGS=}"
                echo "从命令行参数获取额外参数: $EXTRA_ARGS"
                shift
                ;;
            *)
                echo "警告: 未知参数 '$1'，已忽略"
                shift
                ;;
        esac
    done

    # 检查环境变量 ARGS（如果命令行未指定）
    if [ -n "$ARGS" ] && [ -z "$EXTRA_ARGS" ]; then
        EXTRA_ARGS="$ARGS"
        echo "从环境变量 ARGS 获取额外参数: $EXTRA_ARGS"
    fi

    if [ $RELOAD_MODE -eq 1 ]; then
        # 重载模式：查找并加载ses文件
        find_ses_file
        verdi_cmd="verdi -nologo -ssr \"$SES_FILE\""
    else
        # 正常模式：加载fsdb和源文件
        # 检查前提条件
        check_prerequisites

        # 查找fsdb文件
        find_fsdb_file

        # 读取源文件
        read_source_files

        # 显示文件信息
        echo "文件列表: ${FILELIST#$PROJECT_ROOT/}"
        echo "源文件数量: ${#SRC_FILES[@]}"
        echo "=========================================="

        # 构建Verdi命令
        verdi_cmd="verdi -nologo -ssf \"$FSDB_FILE\" -2001 -sverilog"
        for file in "${SRC_FILES[@]}"; do
            verdi_cmd="$verdi_cmd \"$file\""
        done
    fi

    # 添加额外参数
    if [ -n "$EXTRA_ARGS" ]; then
        verdi_cmd="$verdi_cmd $EXTRA_ARGS"
    fi

    echo "执行命令: $verdi_cmd"
    echo "=========================================="
    
    # 启动Verdi
    eval $verdi_cmd &
    
    if [ $? -eq 0 ]; then
        echo "Verdi启动成功!"
        echo "Verdi进程ID: $!"
    else
        echo "Verdi启动失败!"
        exit 1
    fi
}

# 运行主函数
main "$@"
