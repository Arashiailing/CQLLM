/**
 * @name Total lines of Python code in the database
 * @description 计算数据库中所有Python文件的代码行总数，包括外部库和自动生成的文件。
 *   该指标是衡量数据库规模的有效方式。此查询计算代码行数，不包括空白行或注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析模块，用于处理Python代码库的度量指标

// 遍历所有Python模块，计算代码行数总和
// 此查询统计数据库中所有Python模块的有效代码行数（排除空白行和注释）
from Module pythonModule
select sum(pythonModule.getMetrics().getNumberOfLinesOfCode())