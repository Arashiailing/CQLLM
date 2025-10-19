/**
 * @name Python文件提取结果
 * @description 识别并列出代码库中所有已成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 本查询旨在检测并报告代码库中所有成功提取的Python源文件。
 * 成功提取的定义标准：文件在代码库中具有有效的相对路径。
 * 这类文件通常是指那些能够被正确解析和处理的有效Python源代码文件。
 */
from File extractedPythonSource
where exists(extractedPythonSource.getRelativePath())
select extractedPythonSource, ""  // 输出文件路径和空字符串（用于格式化）