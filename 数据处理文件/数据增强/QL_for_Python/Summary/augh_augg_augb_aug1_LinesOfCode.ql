/**
 * @name Python代码总行数统计
 * @description 提供对整个Python代码库规模的量化评估，计算所有Python文件的实际代码行数总和。
 *   该统计包括外部依赖库和自动生成的代码文件，但排除空白行和注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析工具包，提供Python代码分析的基础能力

from Module pyModule
select sum(pyModule.getMetrics().getNumberOfLinesOfCode())
// 解释：
// - `Module` 表示Python代码中的一个模块单元
// - 变量 `pyModule` 遍历数据库中的每个Python模块
// - `getMetrics()` 方法获取模块的度量信息
// - `getNumberOfLinesOfCode()` 从度量信息中提取有效的代码行数（不包括空白行和注释）
// - `sum(...)` 函数对所有模块的代码行数进行汇总，得出整个代码库的总行数