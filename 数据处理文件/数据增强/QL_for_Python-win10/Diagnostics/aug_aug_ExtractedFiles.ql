/**
 * @name Python文件提取结果
 * @description 识别并列出代码库中所有已成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 此查询用于识别已成功提取的Python源文件。
 * 成功提取的判定标准：文件具有有效的相对路径。
 */
from File extractedPythonFile
where exists(extractedPythonFile.getRelativePath())
select extractedPythonFile, ""  // 输出文件路径和空字符串（用于格式化）