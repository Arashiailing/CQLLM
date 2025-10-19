/**
 * @name 已成功提取的Python源文件
 * @description 识别并列出所有在源代码分析过程中成功提取的Python文件。
 *              成功提取的文件是指那些具有可访问相对路径的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 查询所有成功提取的Python源文件
from File extractedFile
where
  // 文件必须具有可访问的相对路径
  exists(extractedFile.getRelativePath())
// 输出文件实例和格式化占位符
select extractedFile, ""