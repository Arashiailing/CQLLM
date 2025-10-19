/**
 * @name Total lines of Python code in the database
 * @description The total number of lines of Python code across all files, including
 *   external libraries and auto-generated files. This is a useful metric of the size of a
 *   database. This query counts the lines of code, excluding whitespace or comments.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析模块，提供Python代码分析功能

// 计算所有Python模块的代码行数总和
select sum(Module codeModule | | codeModule.getMetrics().getNumberOfLinesOfCode())
// 说明：
// - `Module` 类代表Python代码模块
// - `codeModule` 是模块实例变量
// - `getMetrics().getNumberOfLinesOfCode()` 方法获取模块的有效代码行数（不含空行和注释）
// - `sum(...)` 聚合函数计算所有模块代码行数的总和