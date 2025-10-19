/**
 * @name Outgoing class dependencies
 * @description Measures the count of external classes that each class relies upon.
 *              This metric indicates how coupled a class is to other components.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// Analyze class metrics to determine efferent coupling (outgoing dependencies)
// Higher values indicate classes with more external dependencies
from ClassMetrics analyzedClass
select analyzedClass, analyzedClass.getEfferentCoupling() as dependencyCount order by dependencyCount desc