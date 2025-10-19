/**
 * @name Python代码总行数统计
 * @description 计算数据库中所有Python文件的总代码行数，包括外部库和自动生成的文件。
 *   此指标用于评估代码库规模，仅统计实际代码行，不包含空白行和注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析模块，提供Python代码分析的核心功能

// 遍历所有Python模块
from Module pythonModule
// 计算所有模块的代码行数总和
select sum(pythonModule.getMetrics().getNumberOfLinesOfCode())