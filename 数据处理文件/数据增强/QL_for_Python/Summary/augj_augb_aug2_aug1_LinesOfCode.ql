/**
 * @name Python代码库规模度量
 * @description 计算Python代码库中所有源文件的有效代码行总数，包括第三方依赖和自动生成的代码。
 *   此度量指标用于评估代码库的整体规模。计数只包含实际执行的代码行，排除空行和注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析库，提供Python源代码解析与分析能力

// 声明查询变量：sourceModule表示Python源代码模块，effectiveLines表示该模块的有效代码行数
from Module sourceModule, int effectiveLines
// 关联变量：通过模块的度量指标获取有效代码行数
where effectiveLines = sourceModule.getMetrics().getNumberOfLinesOfCode()
// 聚合计算：汇总所有模块的有效代码行数，得到代码库总规模
select sum(effectiveLines)