/**
 * @name Python文件提取状态检查
 * @description 识别并报告代码库中所有成功解析的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 此查询用于识别代码库中成功提取的Python源文件。
 * 判断标准：文件具有有效的相对路径，这表示文件已被正确提取和处理。
 */
from File extractedPyFile
where 
  // 确保文件具有有效的相对路径，这是成功提取的关键指标
  exists(extractedPyFile.getRelativePath())
select extractedPyFile, ""  // 输出文件对象和空字符串（保持格式一致性）