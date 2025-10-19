/**
 * @name Python代码库规模统计
 * @description 该查询用于计算Python代码库中所有源文件的有效代码行总数，
 *   包括第三方依赖和自动生成的代码。此指标用于评估代码库的整体规模，
 *   只统计实际执行的代码行，不计算空行和纯注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析模块，提供Python源代码解析与分析的核心功能

from Module pythonModule, int moduleLineCount
where 
  // 获取每个Python模块的代码行数指标
  moduleLineCount = pythonModule.getMetrics().getNumberOfLinesOfCode()
select 
  sum(moduleLineCount) // 计算所有模块代码行数的总和
// 说明：
// - `Module` 类代表Python代码中的模块单元
// - 变量 `pythonModule` 遍历数据库中的所有Python模块
// - 变量 `moduleLineCount` 存储每个模块的有效代码行数
// - `sum(...)` 聚合函数汇总所有模块的代码行数，得出总行数