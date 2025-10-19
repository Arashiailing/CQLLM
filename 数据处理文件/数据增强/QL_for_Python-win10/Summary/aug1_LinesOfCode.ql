/**
 * @name Python代码总行数统计
 * @description 计算数据库中所有Python文件的总代码行数，包括外部库和自动生成的文件。
 *   这是衡量数据库规模的有用指标。此查询计算的是代码行数，不包括空白行或注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python模块，提供与Python代码分析相关的功能

from Module pythonModule
select sum(pythonModule.getMetrics().getNumberOfLinesOfCode())
// 说明：
// - `Module` 类代表一个Python代码模块
// - 变量 `pythonModule` 是 `Module` 类的实例
// - `pythonModule.getMetrics().getNumberOfLinesOfCode()` 方法用于获取模块的代码行数
// - `sum(...)` 聚合函数计算所有模块代码行数的总和