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

// 计算每个Python模块文件中定义的类的数量
from Module fileModule, int classCount

// 统计每个模块文件内定义的类总数
where classCount = count(Class definedClass | 
       definedClass.getEnclosingModule() = fileModule)

// 输出结果：模块文件及其对应的类数量，按类数量降序排列
select fileModule, classCount order by classCount desc