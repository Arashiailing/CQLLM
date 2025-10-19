/**
 * @name Class External Dependency Analysis
 * @description Calculates the number of distinct external classes that each class depends on.
 *              This metric helps identify highly coupled classes that may be harder to maintain and test.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// For each class in the codebase, determine how many external classes it references
from ClassMetrics targetClass
where exists(targetClass.getEfferentCoupling())
select targetClass, 
       targetClass.getEfferentCoupling() as outboundCoupling 
order by outboundCoupling desc