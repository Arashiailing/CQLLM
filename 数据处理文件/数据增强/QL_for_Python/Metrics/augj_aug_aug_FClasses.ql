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

// 查询每个Python模块文件及其包含的类定义数量
from Module fileModule, int classCount

// 计算每个模块文件中定义的类的总数
// 通过统计每个模块中所有类定义的数量来获取
where classCount = count(Class classDef | classDef.getEnclosingModule() = fileModule)

// 输出结果：模块文件和对应的类数量，按类数量降序排列
// 这有助于识别可能包含过多类的文件，可能需要重构
select fileModule, classCount order by classCount desc