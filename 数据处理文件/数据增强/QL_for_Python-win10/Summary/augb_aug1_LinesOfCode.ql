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

from Module pyModule
select sum(pyModule.getMetrics().getNumberOfLinesOfCode())
// 说明：
// - `Module` 类表示一个Python代码模块
// - 变量 `pyModule` 遍历所有Python模块实例
// - `pyModule.getMetrics().getNumberOfLinesOfCode()` 获取模块的代码行数
// - `sum(...)` 聚合函数计算所有模块代码行数的总和