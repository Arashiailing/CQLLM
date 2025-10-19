/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Calculates the Chidamber-Kemerer Lack of Cohesion (LCOM) metric.
 *              This quantifies method dissimilarity within a class, where elevated
 *              scores indicate reduced cohesion and potential refactoring needs.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Identify classes for cohesion analysis
from ClassMetrics targetClass

// Compute LCOM metric for each target class
// Results ordered by descending LCOM values to prioritize
// classes with the most significant cohesion deficiencies
select targetClass, 
       targetClass.getLackOfCohesionCK() as cohesionMetric 
order by cohesionMetric desc