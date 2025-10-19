/**
 * @name Python代码总行数统计
 * @description 统计数据库中所有Python模块的总代码行数，涵盖外部库和自动生成的代码。
 *   该指标用于评估代码库的规模。统计的是实际代码行数，不包含空行和注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析模块，提供Python代码分析的核心功能

from Module codeModule, int locCount
where locCount = codeModule.getMetrics().getNumberOfLinesOfCode()
select sum(locCount)
// 说明：
// - `Module` 类表示一个Python代码模块单元
// - 变量 `codeModule` 是 `Module` 类的实例，代表单个Python模块
// - 变量 `locCount` 存储每个模块的代码行数
// - `where locCount = codeModule.getMetrics().getNumberOfLinesOfCode()` 获取模块的代码行数
// - `sum(locCount)` 聚合函数对所有模块的代码行数求和，得到总行数