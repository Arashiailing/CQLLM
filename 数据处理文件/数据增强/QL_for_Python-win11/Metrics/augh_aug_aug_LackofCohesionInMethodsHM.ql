/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Evaluates the lack of cohesion within classes using Hitz and Montazeri's methodology.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Python module import for code analysis functionality

// This query identifies classes with low cohesion based on the HM (Hitz-Montazeri) method
// The results are presented with the most cohesion-deficient classes listed first
from ClassMetrics classInfo

// Retrieve the class and its corresponding HM cohesion metric value
select 
    classInfo, 
    classInfo.getLackOfCohesionHM() as cohesionMetric

// Sort results to prioritize classes exhibiting the highest lack of cohesion
order by 
    cohesionMetric desc