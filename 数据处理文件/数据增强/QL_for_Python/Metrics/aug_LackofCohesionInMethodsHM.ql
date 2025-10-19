/**
 * @name Lack of Cohesion in a Class (HM)
 * @description Computes the lack of cohesion metric for classes based on Hitz and Montazeri's method.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// Query for classes with their cohesion metrics
// Results are ordered by descending cohesion metric values
from ClassMetrics classMetric
select 
    classMetric, 
    classMetric.getLackOfCohesionHM() as cohesionMetric 
order by 
    cohesionMetric desc