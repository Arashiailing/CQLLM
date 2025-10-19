/**
 * @name Class Cohesion Deficiency (HM)
 * @description This query calculates the lack of cohesion in classes using the Hitz and Montazeri method.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// Retrieve class metrics and compute cohesion deficiency
// Results sorted by highest cohesion deficiency values first
from ClassMetrics clsMetric, float cohesionValue
where cohesionValue = clsMetric.getLackOfCohesionHM()
select 
    clsMetric, 
    cohesionValue 
order by 
    cohesionValue desc