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

// Identify classes with cohesion issues using HM methodology
// The analysis focuses on measuring the relationship between methods and instance variables
from ClassMetrics classMetric

// Retrieve class information and calculate its cohesion deficiency score
// Higher values indicate greater lack of cohesion within the class
select 
    classMetric, 
    classMetric.getLackOfCohesionHM() as cohesionScore 

// Sort results to highlight classes with the most severe cohesion problems first
order by 
    cohesionScore desc