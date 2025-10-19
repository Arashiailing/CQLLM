/**
 * @name 提取的Python文件
 * @description 识别并列出源代码树中所有成功提取的Python源文件。
 *              此查询通过验证文件是否具有有效的相对路径来确认文件是否被正确提取。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 从所有Python文件中筛选出具有有效相对路径的文件
// 这些文件表示已成功从源代码树中提取的Python模块
from File sourceFile
where exists(sourceFile.getRelativePath())
// 输出文件对象和空字符串（用于保持格式一致性）
select sourceFile, ""