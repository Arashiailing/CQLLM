/**
 * @name Python源文件提取状态分析
 * @description 检测并展示代码库中所有有效提取的Python源文件列表。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 本查询旨在识别代码库中成功提取的Python源文件。
 * 提取成功的判定依据：文件具备有效的相对路径。
 */
from File successfullyExtractedFile
where 
  /* 检查文件是否具有有效的相对路径，这是提取成功的标志 */
  exists(successfullyExtractedFile.getRelativePath())
select successfullyExtractedFile, ""  // 输出文件路径和空字符串（用于格式化）