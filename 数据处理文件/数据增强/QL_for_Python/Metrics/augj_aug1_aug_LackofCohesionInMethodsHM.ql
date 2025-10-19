/**
 * @name Class Cohesion Deficiency (Hitz-Montazeri)
 * @description Measures class cohesion deficiency based on Hitz and Montazeri's approach.
 * @kind treemap
 * @id py/class-cohesion-deficiency-hm
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Enables Python code analysis functionality

// This query detects classes with measurable cohesion deficiency
// according to Hitz-Montazeri methodology, sorted by severity
from ClassMetrics classData, float cohesionValue
where cohesionValue = classData.getLackOfCohesionHM() and 
      exists(cohesionValue)
select 
    classData, 
    cohesionValue 
order by 
    cohesionValue desc