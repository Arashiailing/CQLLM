/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Quantifies class cohesion deficiency employing Hitz and Montazeri's approach.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// Identify classes with cohesion issues using Hitz-Montazeri methodology
// This metric evaluates method-attribute connectivity patterns within classes
from ClassMetrics classData

// Generate output prioritizing classes with most severe cohesion deficiencies
// Retrieve class metadata and calculate its cohesion deficiency score
// Higher values indicate more significant cohesion problems in the class
select 
    classData, 
    classData.getLackOfCohesionHM() as cohesionValue 
order by 
    cohesionValue desc