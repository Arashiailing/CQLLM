/**
 * @name 已成功提取的Python源文件
 * @description 识别并列出所有在源代码分析过程中成功提取的Python文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 定义查询范围：所有Python源文件
from File successfullyExtractedFile
// 筛选条件：文件必须具有可访问的相对路径
where exists(successfullyExtractedFile.getRelativePath())
// 输出结果：文件实例和格式化占位符
select successfullyExtractedFile, ""