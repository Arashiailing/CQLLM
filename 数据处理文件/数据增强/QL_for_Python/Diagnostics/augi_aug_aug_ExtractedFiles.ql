/**
 * @name Python源文件提取状态检查
 * @description 检测并报告代码库中所有成功提取的Python源文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

/* 
 * 该查询用于检测代码库中成功提取的Python源文件。
 * 判断文件是否成功提取的标准：文件存在有效的相对路径。
 */
from File pythonSourceFile
where 
  exists(pythonSourceFile.getRelativePath())
select pythonSourceFile, ""  // 输出文件路径和空字符串（用于格式化）