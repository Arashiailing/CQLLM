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

// This query analyzes class cohesion deficiency based on Hitz-Montazeri methodology
// It identifies classes with measurable cohesion issues and ranks them by severity
from ClassMetrics classCohesionMetric
// Filter classes that have a calculable Hitz-Montazeri cohesion deficiency value
where exists(classCohesionMetric.getLackOfCohesionHM())
select 
    classCohesionMetric,  // The class being analyzed
    classCohesionMetric.getLackOfCohesionHM() as hmCohesionValue  // Cohesion deficiency score
order by 
    hmCohesionValue desc  // Sort from highest (worst) to lowest deficiency