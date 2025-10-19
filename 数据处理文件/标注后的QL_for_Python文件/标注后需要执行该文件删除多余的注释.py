import os
from pathlib import Path

def remove_first_and_last_lines(file_path):
    """删除文件的第一行和最后一行"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        
        # 检查行数是否足够执行删除操作
        if len(lines) < 2:
            print(f"警告：文件过短，无法删除首尾行: {file_path}")
            return False
        
        # 删除第一行和最后一行
        modified_lines = lines[1:-1]
        
        # 将修改后的内容写回文件
        with open(file_path, 'w', encoding='utf-8') as file:
            file.writelines(modified_lines)
        
        return True
    
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {str(e)}")
        return False

def process_ql_files(directory):
    """遍历目录并处理所有QL文件"""
    total_files = 0
    processed_files = 0
    failed_files = []
    
    print(f"开始处理目录: {directory}")
    
    # 遍历所有QL文件
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.ql'):
                total_files += 1
                file_path = Path(root) / file
                
                # 处理文件
                print(f"正在处理: {file_path}")
                success = remove_first_and_last_lines(file_path)
                
                if success:
                    processed_files += 1
                else:
                    failed_files.append(str(file_path))
    
    # 打印处理结果
    print("\n" + "="*50)
    print(f"处理完成! 总文件数: {total_files}")
    print(f"成功处理: {processed_files}")
    print(f"处理失败: {len(failed_files)}")
    
    # 保存失败文件列表
    if failed_files:
        log_path = Path(directory) / "removal_errors.log"
        with open(log_path, 'w', encoding='utf-8') as log_file:
            log_file.write("处理失败的文件列表:\n\n")
            for file_path in failed_files:
                log_file.write(f"{file_path}\n")
        
        print(f"\n失败文件列表已保存至: {log_path}")

if __name__ == '__main__':
    # 要处理的目录 - 修改为您的实际目录
    target_directory = r'C:\code\CQLLM\v2.0\标注后的QL_for_Python文件\标注后的QL_for_Python文件'
    
    # 开始处理
    process_ql_files(target_directory)