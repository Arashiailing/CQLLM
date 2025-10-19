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

// Analyze each class in the codebase to determine its external dependencies
from ClassMetrics analyzedClass
where exists(analyzedClass.getEfferentCoupling())
select analyzedClass, 
       analyzedClass.getEfferentCoupling() as efferentCouplingCount 
order by efferentCouplingCount desc