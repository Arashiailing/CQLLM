/**
 * @name 已成功提取的Python源文件
 * @description 此查询用于检测并报告所有在代码分析过程中成功提取的Python源文件。
 *              成功提取的文件是指那些具有可访问相对路径的Python文件。
 * @kind diagnostic
 * @id py/diagnostics/successfully-extracted-files
 * @tags successfully-extracted-files
 */

import python

// 定义查询范围：所有Python源文件
from File pySourceFile
// 应用筛选条件：文件必须具有可访问的相对路径，这表明文件已成功提取
where exists(pySourceFile.getRelativePath())
// 输出结果：文件实例和空字符串（作为占位符）
select pySourceFile, ""