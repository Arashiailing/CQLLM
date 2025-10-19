/**
 * @name External class coupling analysis
 * @description Measures the count of outgoing dependencies for every class.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 计算每个类引用的外部依赖项数量，评估类与其他组件的耦合强度
// 输出结果按照依赖数量从高到低排序，便于发现可能需要解耦的类
from ClassMetrics targetClass
where exists(targetClass.getEfferentCoupling())
select targetClass, 
       targetClass.getEfferentCoupling() as couplingCount 
order by couplingCount desc