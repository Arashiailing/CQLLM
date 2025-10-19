/**
 * @name Python代码库规模度量
 * @description 计算整个Python代码库的代码行数总量，包括第三方库和自动生成的代码。
 *   此指标用于评估代码库的整体规模。统计仅计算实际代码行，不包括空行和注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析支持库，提供代码解析与分析能力

from Module sourceModule
select sum(sourceModule.getMetrics().getNumberOfLinesOfCode())
// 说明：
// - `Module` 类代表Python代码中的模块单元
// - 变量 `sourceModule` 遍历数据库中的所有Python模块
// - `getMetrics().getNumberOfLinesOfCode()` 方法链获取每个模块的有效代码行数
// - `sum(...)` 聚合函数将所有模块的代码行数累加，得出总量