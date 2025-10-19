/**
 * @name Class Efferent Coupling Analysis
 * @description Measures and quantifies the degree to which a class relies on other classes (efferent coupling).
 *              Higher values indicate classes with more external dependencies, potentially affecting modularity.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// Analyze each class to determine its count of external dependencies
from ClassMetrics examinedClass
select examinedClass, 
       examinedClass.getEfferentCoupling() as externalDependencyCount 
order by externalDependencyCount desc