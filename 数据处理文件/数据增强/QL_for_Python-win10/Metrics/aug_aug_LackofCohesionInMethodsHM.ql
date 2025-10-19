/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Evaluates the lack of cohesion within classes using Hitz and Montazeri's methodology.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// Query to analyze class cohesion metrics
// Results are sorted in descending order of cohesion deficiency
from ClassMetrics clsMetric

// Select class and its cohesion metric
select 
    clsMetric, 
    clsMetric.getLackOfCohesionHM() as cohesionMetric 

// Order by highest cohesion deficiency first
order by 
    cohesionMetric desc