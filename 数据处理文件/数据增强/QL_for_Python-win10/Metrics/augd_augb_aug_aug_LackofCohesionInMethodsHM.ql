/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Measures the lack of cohesion in classes based on Hitz and Montazeri's methodology.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// Detect classes with cohesion problems using Hitz-Montazeri (HM) methodology
// This metric quantifies the relationship between methods and instance variables
from ClassMetrics clsMetrics

// Extract class details and compute the cohesion deficiency score
// Elevated scores indicate more significant cohesion issues within the class
select 
    clsMetrics, 
    clsMetrics.getLackOfCohesionHM() as lhmScore 

// Arrange results to emphasize classes with the most critical cohesion deficiencies
order by 
    lhmScore desc