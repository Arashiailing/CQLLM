/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Calculates the Chidamber-Kemerer Lack of Cohesion in Methods (LCOM) metric.
 *              This quantifies method dissimilarity within classes, where elevated scores
 *              indicate reduced cohesion and potential refactoring opportunities.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Identify classes targeted for cohesion analysis
from ClassMetrics targetClass

// Compute LCOM metric for each target class
// Results sorted descending to prioritize high-discrepancy classes
select targetClass,
       targetClass.getLackOfCohesionCK() as lcomScore
order by lcomScore desc