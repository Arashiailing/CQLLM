/**
 * @name Total lines of Python code in the database
 * @description The total number of lines of Python code across all files, including
 *   external libraries and auto-generated files. This is a useful metric of the size of a
 *   database. This query counts the lines of code, excluding whitespace or comments.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析模块，用于处理Python代码库的度量计算

// 遍历所有Python模块，计算代码行数总和
// 此查询统计数据库中所有Python模块的有效代码行数（排除空白和注释）
from Module codeModule
select sum(codeModule.getMetrics().getNumberOfLinesOfCode())