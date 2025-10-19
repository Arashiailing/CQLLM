/**
 * @name Outgoing class dependencies
 * @description Measures the external coupling by counting dependencies each class has on other components.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// This analysis calculates efferent coupling for each class, which represents the number of
// external dependencies a class has on other components. High efferent coupling indicates
// reduced modularity and potential difficulties in testing, maintenance, and reuse.
// Classes are sorted by coupling strength to prioritize refactoring efforts.
from ClassMetrics analyzedClass
where exists(analyzedClass.getEfferentCoupling())
select analyzedClass, 
       analyzedClass.getEfferentCoupling() as efferentCouplingCount 
order by efferentCouplingCount desc