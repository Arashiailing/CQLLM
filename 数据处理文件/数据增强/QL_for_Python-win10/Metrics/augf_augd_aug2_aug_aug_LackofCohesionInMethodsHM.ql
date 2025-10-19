/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Measures class cohesion deficiency based on Hitz and Montazeri's methodology.
 *               Higher values indicate more severe cohesion issues within the class.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Essential module for Python class cohesion analysis

// This query identifies classes with poor cohesion by applying the HM method
// Classes are ranked by their cohesion deficiency, with higher values indicating worse cohesion
from ClassMetrics classMetrics
select 
    classMetrics, 
    classMetrics.getLackOfCohesionHM() as cohesionValue 
order by 
    cohesionValue desc