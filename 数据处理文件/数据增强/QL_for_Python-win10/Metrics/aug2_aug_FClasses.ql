/**
 * @name Classes per file
 * @description Measures the number of classes in a file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// 定义源文件及其包含的类数量
from Module sourceFile, int classCount
// 统计每个源文件中定义的类的总数
where classCount = count(Class classDefinition | classDefinition.getEnclosingModule() = sourceFile)
// 输出源文件及其类数量，按类数量降序排列
select sourceFile, classCount order by classCount desc