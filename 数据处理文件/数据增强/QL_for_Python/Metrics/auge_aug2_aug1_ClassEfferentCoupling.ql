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

// This query identifies classes with high external coupling by counting their outgoing dependencies
// Higher values indicate classes that depend on many external components, potentially making them
// harder to test, maintain, and reuse. Results are sorted to highlight the most coupled classes.
from ClassMetrics targetClass
where exists(targetClass.getEfferentCoupling())
select targetClass, 
       targetClass.getEfferentCoupling() as outgoingCoupling 
order by outgoingCoupling desc