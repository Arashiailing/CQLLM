/**
 * @name Class Cohesion Deficiency (Hitz-Montazeri)
 * @description Evaluates the deficiency in class cohesion using the methodology proposed by Hitz and Montazeri.
 * @kind treemap
 * @id py/class-cohesion-deficiency-hm
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// This query identifies classes and evaluates their cohesion deficiency
// using the Hitz-Montazeri methodology, ordered from highest to lowest deficiency
from ClassMetrics clsMetric
where exists(clsMetric.getLackOfCohesionHM())
select 
    clsMetric, 
    clsMetric.getLackOfCohesionHM() as cohesionValue 
order by 
    cohesionValue desc