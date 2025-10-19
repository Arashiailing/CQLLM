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

from Module pyModule, int linesOfCode
where linesOfCode = pyModule.getMetrics().getNumberOfLinesOfCode()
select sum(linesOfCode)
// 说明：
// - `Module` 类代表Python代码中的模块单元
// - 变量 `pyModule` 遍历数据库中的所有Python模块
// - 变量 `linesOfCode` 存储每个模块的有效代码行数
// - `sum(...)` 聚合函数汇总所有模块的代码行数，得出总行数