/**
 * @name 提取的Python文件
 * @description 列出源代码目录中所有成功提取的Python文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 从File类中选择文件
from File file
// 条件：文件存在相对路径
where exists(file.getRelativePath())
// 选择文件和空字符串（用于格式化输出）
select file, ""
