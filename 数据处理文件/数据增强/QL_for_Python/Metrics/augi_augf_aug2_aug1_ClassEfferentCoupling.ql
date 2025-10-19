/**
 * @name Outgoing class dependencies
 * @description Measures the count of external dependencies for each class to evaluate coupling.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 分析传出耦合：衡量一个类依赖其他类的程度
// 高传出耦合值表明类对外部依赖较多，可能降低模块化和可测试性
// 通过量化这些依赖，可以识别需要重构的紧密耦合类
// 结果按传出耦合数量降序排列，优先显示高耦合类
from ClassMetrics examinedClass
where exists(examinedClass.getEfferentCoupling())
select examinedClass, 
       examinedClass.getEfferentCoupling() as efferentCouplingValue 
order by efferentCouplingValue desc