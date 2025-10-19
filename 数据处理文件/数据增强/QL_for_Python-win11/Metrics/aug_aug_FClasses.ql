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

// 从源代码模块中识别每个文件及其包含的类数量
from Module sourceFile, int numberOfClasses

// 计算每个源文件中定义的类的总数
where numberOfClasses = count(Class cls | cls.getEnclosingModule() = sourceFile)

// 输出结果：文件模块和对应的类数量，并按类数量降序排列
select sourceFile, numberOfClasses order by numberOfClasses desc