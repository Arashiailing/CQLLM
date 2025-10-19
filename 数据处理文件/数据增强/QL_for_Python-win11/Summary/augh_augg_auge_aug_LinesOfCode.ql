/**
 * @name Python代码库总行数统计
 * @description 统计数据库中所有Python源文件的有效代码行总数，涵盖外部库和自动生成的文件。
 *   该指标用于评估代码库的整体规模。计算仅包括有效代码行，不计算空白行和注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析模块，用于处理Python代码库的度量分析

// 遍历数据库中的每个Python模块
from Module pyModule
// 累加所有模块的有效代码行数
select sum(pyModule.getMetrics().getNumberOfLinesOfCode())