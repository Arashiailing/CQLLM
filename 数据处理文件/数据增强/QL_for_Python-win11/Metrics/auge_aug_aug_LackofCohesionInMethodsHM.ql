/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Measures the degree of cohesion deficiency in Python classes
 *              by implementing the Hitz and Montazeri (HM) methodology.
 *              Higher values indicate greater lack of cohesion.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Python analysis module providing class metrics capabilities

// This query identifies classes with poor internal cohesion
// Results are presented in descending order of cohesion deficiency
from ClassMetrics classMetrics
where exists(classMetrics.getLackOfCohesionHM())
select 
    classMetrics, 
    classMetrics.getLackOfCohesionHM() as cohesionDeficiency 
order by 
    cohesionDeficiency desc