/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Evaluates class cohesion deficiency using Hitz and Montazeri's methodology.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// This query detects classes exhibiting poor cohesion
// Results are ordered to highlight classes with the most severe cohesion issues
from ClassMetrics clsMetrics
select 
    clsMetrics, 
    clsMetrics.getLackOfCohesionHM() as cohesionScore 
order by 
    cohesionScore desc