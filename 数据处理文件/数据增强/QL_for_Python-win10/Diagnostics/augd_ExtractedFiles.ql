/**
 * @name 成功提取的Python文件清单
 * @description 识别并列出源代码树中所有已成功提取的Python文件，这些文件具有有效的相对路径。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 查询所有具有有效相对路径的Python文件
from File extractedFile
where exists(extractedFile.getRelativePath())
// 输出文件对象和空字符串（用于诊断格式化）
select extractedFile, ""