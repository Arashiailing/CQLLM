/**
 * @name Total lines of Python code in the database
 * @description 计算数据库中所有Python源文件的有效代码行总数，包含第三方库和自动生成的代码。
 *   该度量指标用于评估项目的整体规模。统计范围仅限于实际代码行，排除空行和注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析模块，用于处理Python代码库的度量分析

// 遍历数据库中的每个Python模块，获取其代码度量信息
// 然后计算所有模块的有效代码行总数，排除注释和空白行
from Module pythonModule
select sum(pythonModule.getMetrics().getNumberOfLinesOfCode())