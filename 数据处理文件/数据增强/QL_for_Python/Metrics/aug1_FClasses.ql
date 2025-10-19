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

// 查询每个文件单元中定义的类的数量
// 使用变量 `fileUnit` 表示文件单元，`numClasses` 表示类的数量
from Module fileUnit, int numClasses
// 计算条件：`numClasses` 等于文件单元 `fileUnit` 中所有类的总数
where 
  // 计算文件单元中的类数量
  numClasses = count(Class classDef | 
    // 类定义位于当前文件单元中
    classDef.getEnclosingModule() = fileUnit
  )
// 输出结果：文件单元及其包含的类的数量，按类的数量降序排列
select fileUnit, numClasses order by numClasses desc