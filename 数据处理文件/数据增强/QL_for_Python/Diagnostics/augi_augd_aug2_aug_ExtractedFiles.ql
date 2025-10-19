/**
 * @name 已成功提取的Python源文件
 * @description 此查询用于检测并返回所有在分析过程中成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 查询目标：识别所有成功提取的Python源文件
from File successfullyExtractedPyFile
// 过滤条件：验证文件具有有效的相对路径，表明文件已成功提取
where successfullyExtractedPyFile.getRelativePath() instanceof string
// 输出：返回文件对象和空消息字符串
select successfullyExtractedPyFile, ""