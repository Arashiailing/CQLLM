/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Evaluates the deficiency of class cohesion using Hitz and Montazeri's methodology.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Required Python module for performing class cohesion analysis

// This query analyzes Python classes to identify cohesion deficiencies
// The results prioritize classes with the most severe cohesion issues
from ClassMetrics clsInfo
select 
    clsInfo, 
    clsInfo.getLackOfCohesionHM() as cohesionValue 
order by 
    cohesionValue desc