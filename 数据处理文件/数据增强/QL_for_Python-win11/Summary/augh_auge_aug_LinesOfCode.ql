/**
 * @name Total lines of Python code in the database
 * @description 提供数据库中所有Python源文件的代码行总数统计，涵盖外部库和自动生成的代码。
 *   此指标用于评估代码库的整体规模，仅计算实际代码行，不包括空白行和注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析模块，用于处理Python代码库的度量分析

// 统计所有Python模块的有效代码行数
// 遍历数据库中的每个Python模块，获取其有效代码行数（排除空白行和注释），然后计算总和
from Module sourceModule, int codeLines
where codeLines = sourceModule.getMetrics().getNumberOfLinesOfCode()
select sum(codeLines)