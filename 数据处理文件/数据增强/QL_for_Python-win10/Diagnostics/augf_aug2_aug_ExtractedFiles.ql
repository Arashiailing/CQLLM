/**
 * @name 已成功提取的Python源文件
 * @description 此查询用于检测并列出所有在源代码分析过程中成功提取的Python文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

from File extractedPythonFile
where exists(extractedPythonFile.getRelativePath())
select extractedPythonFile, ""