/**
 * @name Python代码总行数统计
 * @description 计算数据库中所有Python文件的总代码行数，包括外部库和自动生成的文件。
 *   这是衡量数据库规模的有用指标。此查询计算的是代码行数，不包括空白行或注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析库，用于处理Python代码分析任务

from Module pySourceFile
select sum(pySourceFile.getMetrics().getNumberOfLinesOfCode())
// 说明：
// - `Module` 类表示一个Python源代码文件或模块
// - 变量 `pySourceFile` 是 `Module` 类的实例，代表一个Python源文件
// - `pySourceFile.getMetrics().getNumberOfLinesOfCode()` 方法获取该模块的实际代码行数（不包括空行和注释）
// - `sum(...)` 聚合函数对所有模块的代码行数求和，得到总代码行数