/**
 * @name Class Efferent Coupling Analysis
 * @description Quantifies the number of external dependencies for each class in the codebase.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// Examine each class to determine its count of external dependencies
from ClassMetrics targetClass
select targetClass, 
       targetClass.getEfferentCoupling() as externalDependencies 
order by externalDependencies desc