/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Measures the deficiency of cohesion in classes by applying Hitz and Montazeri's method.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Python module import for code analysis functionality

// This query identifies classes with cohesion issues
// Results display classes with the most significant cohesion problems first
from ClassMetrics classMetrics
select 
    classMetrics, 
    classMetrics.getLackOfCohesionHM() as cohesionValue 
order by 
    cohesionValue desc