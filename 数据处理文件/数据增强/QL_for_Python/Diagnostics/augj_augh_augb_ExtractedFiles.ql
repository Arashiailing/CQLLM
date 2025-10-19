/**
 * @name 成功提取的Python源文件识别
 * @description 本查询旨在检测并报告项目中所有成功提取的Python源文件。
 *              通过检查文件对象是否包含有效的相对路径，我们能够确认这些文件
 *              已被正确地从源代码树中提取出来。这一步骤对于确保代码分析的
 *              完整性和准确性至关重要，为后续的安全检查和质量评估奠定基础。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 定义查询范围：所有Python源文件
// 筛选条件：文件必须具有有效的相对路径，这表明文件已成功提取
from File successfullyExtractedPyFile
where exists(successfullyExtractedPyFile.getRelativePath())
// 输出结果：文件对象和空字符串（保持输出格式一致性）
select successfullyExtractedPyFile, ""