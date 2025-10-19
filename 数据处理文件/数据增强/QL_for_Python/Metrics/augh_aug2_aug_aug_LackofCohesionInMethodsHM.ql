/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Quantifies the lack of cohesion within classes using the Hitz and Montazeri methodology.
 *               Higher values indicate more significant cohesion problems.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Importing Python analysis module to enable class metrics evaluation

// This analysis detects classes exhibiting poor cohesion characteristics
// Output is ordered to highlight classes with the most severe cohesion deficiencies
from ClassMetrics clsMetrics
select 
    clsMetrics, 
    clsMetrics.getLackOfCohesionHM() as cohesionScore 
order by 
    cohesionScore desc