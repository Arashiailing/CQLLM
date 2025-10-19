/**
 * @name Python代码库规模统计
 * @description 计算整个Python代码库的实际代码行数总和，用于量化评估项目规模。
 *   统计范围包括所有Python模块（包含外部依赖和生成代码），但不计入空白行和注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析工具包，提供Python代码分析的基础能力

from Module codeModule
where exists(codeModule.getMetrics())
select sum(codeModule.getMetrics().getNumberOfLinesOfCode())
// 解释：
// - `Module` 表示Python代码中的一个模块单元
// - 变量 `codeModule` 遍历数据库中的每个Python模块
// - `where exists(codeModule.getMetrics())` 确保只统计有度量信息的模块
// - `getMetrics()` 方法获取模块的度量信息
// - `getNumberOfLinesOfCode()` 从度量信息中提取有效的代码行数（不包括空白行和注释）
// - `sum(...)` 函数对所有模块的代码行数进行汇总，得出整个代码库的总行数