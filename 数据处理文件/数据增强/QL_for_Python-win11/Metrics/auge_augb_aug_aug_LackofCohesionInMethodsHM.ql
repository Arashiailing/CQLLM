/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Evaluates class cohesion deficiency using Hitz and Montazeri's methodology.
 *              This metric quantifies how dispersed instance variables are across methods,
 *              where higher scores indicate poorer class cohesion.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Import Python module for code analysis capabilities

// Extract class metrics to analyze cohesion based on HM methodology
// The HM method measures the relationship between methods and instance variables
// to determine how well-focused a class's responsibilities are
from ClassMetrics classInfo

// Select each class along with its HM cohesion deficiency score
// The score represents the degree of cohesion lack, with higher values
// indicating more significant structural issues within the class
select 
    classInfo, 
    classInfo.getLackOfCohesionHM() as hmCohesionDeficiency 

// Sort results in descending order of cohesion deficiency
// This prioritizes classes that require immediate refactoring attention
// due to their poor internal cohesion
order by 
    hmCohesionDeficiency desc