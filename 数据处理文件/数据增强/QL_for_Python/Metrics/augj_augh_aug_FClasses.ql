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

// 计算每个Python模块中直接定义的类的总数
from Module pyModule, int classCount
where classCount = count(Class definedClass | definedClass.getEnclosingModule() = pyModule)
// 输出结果：模块及其包含的类数量，按类数量降序排列以突出显示包含最多类的文件
select pyModule, classCount order by classCount desc