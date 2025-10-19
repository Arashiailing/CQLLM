/**
 * @name 提取的Python文件
 * @description 此查询用于识别并列出源代码树中所有成功提取的Python源文件。
 *              通过验证文件是否具有有效的相对路径，我们可以确认文件是否被正确提取。
 *              这是代码分析过程中的重要步骤，确保后续分析基于完整的源代码。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 查询所有Python文件，并筛选出具有有效相对路径的文件
// 这些文件表示已成功从源代码树中提取的Python模块
from File extractedPyFile
where exists(extractedPyFile.getRelativePath())
// 输出文件对象和空字符串（保持格式一致性）
select extractedPyFile, ""