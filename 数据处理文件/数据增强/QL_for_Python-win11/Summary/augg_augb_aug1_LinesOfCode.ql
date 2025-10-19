/**
 * @name Python代码总行数统计
 * @description 提供对整个Python代码库规模的量化评估，计算所有Python文件的实际代码行数总和。
 *   该统计包括外部依赖库和自动生成的代码文件，但排除空白行和注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析工具包，提供Python代码分析的基础功能

from Module codeModule
select sum(codeModule.getMetrics().getNumberOfLinesOfCode())
// 说明：
// - `Module` 代表Python中的一个代码模块单元
// - 变量 `codeModule` 遍历数据库中的每个Python模块
// - `getMetrics()` 获取模块的度量数据，`getNumberOfLinesOfCode()` 从中提取代码行数
// - `sum(...)` 函数对所有模块的代码行数进行累加，得到总行数