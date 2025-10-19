/**
 * @name Class Efferent Coupling Analysis
 * @description Measures the count of external classes that a given class relies on.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 计算每个类的外部依赖数量，量化其出向耦合度
from ClassMetrics examinedClass, int outboundCouplingMetric
where outboundCouplingMetric = examinedClass.getEfferentCoupling()
select examinedClass, 
       outboundCouplingMetric 
order by outboundCouplingMetric desc