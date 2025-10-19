/**
 * @name Python文件提取状态检查
 * @description 检测并报告代码库中所有已成功解析的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 此查询用于识别代码库中成功提取的Python源文件。
 * 判定依据：文件具有有效的相对路径，这表明文件已被系统正确提取并纳入分析范围。
 * 相对路径的存在性是文件成功提取的可靠指标，确保了后续代码分析的可行性。
 */
from File extractedPyFile
where 
  /* 检查文件是否具有有效的相对路径
   * 这是确认文件已被成功提取的关键条件 */
  exists(extractedPyFile.getRelativePath())
select extractedPyFile, ""  // 输出文件对象和空字符串（维持结果格式一致性）