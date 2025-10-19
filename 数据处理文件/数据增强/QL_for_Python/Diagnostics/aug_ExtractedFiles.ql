/**
 * @name 已成功提取的Python源文件
 * @description 识别并列出所有在源代码分析过程中成功提取的Python文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 选取具有相对路径的Python文件实例
from File extractedFile
where exists(extractedFile.getRelativePath())
// 输出文件实例和格式化用的空字符串
select extractedFile, ""