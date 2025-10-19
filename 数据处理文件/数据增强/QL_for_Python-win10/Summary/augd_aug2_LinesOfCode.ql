/**
 * @name Total lines of Python code in the database
 * @description Aggregates the count of Python code lines throughout all files in the database,
 *   including external libraries and auto-generated files. This metric provides insight into
 *   the overall size of the codebase. The calculation specifically excludes whitespace and
 *   comment lines, focusing only on actual code.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析模块，提供Python代码分析功能

// 计算所有Python模块的代码行数总和
select sum(Module sourceFile | | sourceFile.getMetrics().getNumberOfLinesOfCode())
// 说明：
// - `Module` 类代表Python代码模块
// - `sourceFile` 是模块实例变量
// - `getMetrics().getNumberOfLinesOfCode()` 方法获取模块的有效代码行数（不含空行和注释）
// - `sum(...)` 聚合函数计算所有模块代码行数的总和