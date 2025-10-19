/**
 * @name Python文件提取状态验证
 * @description 识别并列出代码库中所有成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 该查询用于验证Python源文件的提取状态。
 * 提取成功的标准：文件具备有效的相对路径，表明文件已被系统正确处理和索引。
 * 此查询有助于确认代码库中哪些Python文件可供进一步分析。
 */
from File pythonSrcFile
where 
  /* 验证文件是否成功提取：检查相对路径是否存在且有效 */
  pythonSrcFile.getRelativePath() != "" and
  exists(pythonSrcFile.getRelativePath())
select pythonSrcFile, ""  // 输出文件对象和空字符串（保持结果格式一致性）