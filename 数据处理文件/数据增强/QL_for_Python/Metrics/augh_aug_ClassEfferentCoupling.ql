/**
 * @name Class Efferent Coupling Analysis
 * @description Quantifies the number of distinct external classes that each class depends on.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// Evaluate the external coupling for each class in the codebase
from ClassMetrics targetClass
select targetClass, 
       targetClass.getEfferentCoupling() as externalDependencyCount 
order by externalDependencyCount desc