/**
 * @name Python代码总行数统计
 * @description 统计整个代码库中Python源文件的总代码行数，包括外部库和自动生成的代码。
 *   该指标用于量化代码库的规模，仅计算有效的代码行，排除空白行和注释行。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 导入Python分析模块，提供Python代码分析的核心功能

// 从数据库中提取所有Python源文件模块
from Module sourceModule
// 获取每个模块的代码度量指标，计算有效代码行数，并返回所有模块的总和
select sum(sourceModule.getMetrics().getNumberOfLinesOfCode())