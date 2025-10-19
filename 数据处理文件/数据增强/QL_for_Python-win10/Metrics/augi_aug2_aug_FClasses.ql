/**
 * @name Classes per file
 * @description Calculates and displays the count of classes defined in each Python file
 * @kind treemap
 * @id py/classes-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python

// 声明变量：Python模块文件和其中包含的类的数量
from Module pyFile, int numberOfClasses
// 计算条件：统计每个模块文件中定义的所有类的数量
where numberOfClasses = count(Class cls | cls.getEnclosingModule() = pyFile)
// 输出结果：展示每个文件及其包含的类数量，按数量从高到低排序
select pyFile, numberOfClasses order by numberOfClasses desc