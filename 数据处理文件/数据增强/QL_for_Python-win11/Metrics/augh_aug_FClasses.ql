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

// 定义Python模块及其包含的类数量统计
from Module moduleContainer, int totalClasses
// 计算每个Python模块中直接定义的类的总数
where totalClasses = count(Class cls | cls.getEnclosingModule() = moduleContainer)
// 选择结果：模块及其类数量，并按类数量降序排列以便识别包含最多类的文件
select moduleContainer, totalClasses order by totalClasses desc