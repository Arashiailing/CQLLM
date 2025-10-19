/**
 * @name External class dependencies analysis
 * @description Quantifies the number of distinct external classes that a particular class depends on.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// This analysis measures the efferent coupling metric for each class, indicating
// how many external classes a class relies upon. Higher values suggest tighter
// coupling and potential architectural concerns. Classes are presented in
// descending order of their coupling count to identify those requiring attention.

from ClassMetrics targetClass
where exists(targetClass.getEfferentCoupling())
select targetClass, targetClass.getEfferentCoupling() as couplingCount 
order by couplingCount desc