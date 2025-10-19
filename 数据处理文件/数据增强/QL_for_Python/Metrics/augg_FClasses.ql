/**
 * @name Classes per file
 * @description Analyzes and counts the number of class definitions within each Python module/file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// 遍历每个 Python 模块并计算其中包含的类定义数量
from Module fileModule, int classCount
// 筛选条件：classCount 等于当前模块中所有类定义的总数
where classCount = count(Class classDef | classDef.getEnclosingModule() = fileModule)
// 输出结果：模块文件及其包含的类数量，按数量降序排列
select fileModule, classCount order by classCount desc