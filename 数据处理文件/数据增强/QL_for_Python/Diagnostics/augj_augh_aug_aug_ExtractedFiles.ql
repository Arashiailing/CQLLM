/**
 * @name Python文件提取结果
 * @description 检测并列出代码库中所有已成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 此查询用于识别代码库中所有成功提取的Python源文件。
 * 成功提取的判定条件：文件在代码库中拥有有效的相对路径。
 * 这些文件通常代表可以被正确解析和处理的有效Python源代码文件。
 */
from File validPythonFile
where validPythonFile.getRelativePath() != ""
select validPythonFile, ""  // 输出文件路径和空字符串（用于格式化）