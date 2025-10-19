/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Quantifies the cohesion deficiency in Python classes using
 *              the Hitz and Montazeri (HM) method. Elevated values signify
 *              diminished class cohesion, indicating potential design issues.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Core Python analysis module for class metrics evaluation

// Define the condition for classes with measurable cohesion deficiency
// and calculate their deficiency metric
from ClassMetrics clsMetrics, float deficiency
where 
    exists(clsMetrics.getLackOfCohesionHM()) and
    deficiency = clsMetrics.getLackOfCohesionHM()

// Present results ranked by cohesion deficiency severity
select 
    clsMetrics, 
    deficiency as cohesionDeficiency 
order by 
    cohesionDeficiency desc