/**
 * @name Incoming class dependencies analysis
 * @description Calculates and displays the count of classes that have dependencies on each target class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// 从类度量中获取目标类，并提取其传入耦合（afferent coupling）值
from ClassMetrics targetCls, int couplingCount
where couplingCount = targetCls.getAfferentCoupling() and exists(couplingCount)
select targetCls, 
       couplingCount as dependencyCount 
order by dependencyCount desc