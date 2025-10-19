/**
 * @name Python代码库规模度量
 * @description 统计数据库中所有Python源文件的总行数，涵盖第三方库和生成代码。
 *   该指标反映了代码库的整体规模。统计仅包含实际代码行，忽略空行和注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析模块，提供Python代码解析与分析功能

from Module codeModule
select sum(codeModule.getMetrics().getNumberOfLinesOfCode())
// 注解：
// - `Module` 类表示Python代码模块单元
// - 变量 `codeModule` 遍历所有Python模块实例
// - `getMetrics().getNumberOfLinesOfCode()` 方法链获取模块的有效代码行数
// - `sum(...)` 聚合函数累加所有模块的代码行数，得到总量