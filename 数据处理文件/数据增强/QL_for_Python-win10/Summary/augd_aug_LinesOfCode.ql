/**
 * @name Total lines of Python code in the database
 * @description Calculates the aggregate count of Python code lines throughout the entire
 *   database, encompassing both external libraries and auto-generated files. This metric
 *   provides insight into the overall scale of the codebase. The calculation specifically
 *   excludes blank lines and comments, focusing only on actual code lines.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析模块，用于执行Python代码库的度量分析

// 遍历数据库中的每个Python模块，累加其有效代码行数
// 该查询统计所有Python模块中排除空白行和注释后的实际代码行数总和
from Module pythonModule
select sum(pythonModule.getMetrics().getNumberOfLinesOfCode())