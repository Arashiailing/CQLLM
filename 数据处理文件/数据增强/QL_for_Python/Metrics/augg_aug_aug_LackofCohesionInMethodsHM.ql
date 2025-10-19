/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Evaluates the lack of cohesion within classes using Hitz and Montazeri's methodology.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Python module import for static code analysis

// Identifies classes with poor cohesion using the Hitz-Montazeri method
// Higher values indicate more severe cohesion issues
from ClassMetrics classMetricsData
select classMetricsData, classMetricsData.getLackOfCohesionHM() as lackOfCohesionScore 
order by lackOfCohesionScore desc