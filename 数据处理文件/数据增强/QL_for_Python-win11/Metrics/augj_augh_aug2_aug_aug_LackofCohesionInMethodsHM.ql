/**
 * @name Class Cohesion Deficiency (HM Method)
 * @description Quantifies class cohesion deficiency using Hitz-Montazeri methodology.
 *               Higher scores indicate more severe cohesion issues where class responsibilities
 *               are not properly grouped, potentially violating Single Responsibility Principle.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // Core Python analysis module for class-level metrics evaluation

// Identify classes with cohesion deficiencies by analyzing method interactions
// Results prioritize classes exhibiting the most significant cohesion problems
from ClassMetrics classMetrics
select 
    classMetrics, 
    classMetrics.getLackOfCohesionHM() as cohesionScore 
order by 
    cohesionScore desc