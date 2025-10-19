/**
 * @name 已成功提取的Python源文件
 * @description 此查询用于检测并返回所有在分析过程中成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 查询目标：识别所有成功提取的Python文件
from File extractedPyFile
// 过滤条件：确保文件具有有效的相对路径
where extractedPyFile.getRelativePath() instanceof string
// 输出：返回文件对象和空消息字符串
select extractedPyFile, ""