/**
 * @name Python文件提取状态验证
 * @description 识别并列出代码库中所有成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 此查询用于检测代码库中成功提取的Python源文件集合。
 * 成功提取的判定标准：文件拥有有效的相对路径，这表明文件已被系统正确提取。
 */
from File extractedPythonFile
where 
  /* 文件成功提取的条件：存在有效的相对路径 */
  exists(extractedPythonFile.getRelativePath())
select extractedPythonFile, ""  // 输出文件对象和空字符串（保持格式一致性）