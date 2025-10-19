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

// 定义文件模块和对应的类计数
from Module fileModule, int classCount
// 计算每个模块中的类数量
where classCount = count(Class cls | cls.getEnclosingModule() = fileModule)
// 选择结果并按类数量降序排列
select fileModule, classCount order by classCount desc