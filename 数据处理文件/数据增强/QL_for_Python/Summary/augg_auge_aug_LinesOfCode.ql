/**
 * @name Total lines of Python code in the database
 * @description 提供数据库中所有Python文件的代码行总数统计，包括外部库和自动生成的文件。
 *   此指标用于评估代码库的整体规模。统计仅计算有效代码行，不包括空白行和注释。
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // 引入Python分析模块，用于处理Python代码库的度量分析

// 遍历数据库中的每个Python模块，并累加其有效代码行数
// 此查询旨在提供代码库规模的整体视图，通过统计所有模块的非注释、非空白代码行
from Module sourceFile
select sum(sourceFile.getMetrics().getNumberOfLinesOfCode())