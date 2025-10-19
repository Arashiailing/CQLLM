/**
 * @name Python文件提取状态检查
 * @description 检测并报告代码库中所有已成功解析的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 本查询旨在识别代码库中成功提取的Python源文件。
 * 判断依据：文件存在有效的相对路径，表明文件已被正确提取。
 */
from File successfullyExtractedFile
where 
  // 检查文件是否具有有效的相对路径，这是成功提取的标志
  exists(successfullyExtractedFile.getRelativePath())
select successfullyExtractedFile, ""  // 输出文件对象和空字符串（用于保持格式一致性）