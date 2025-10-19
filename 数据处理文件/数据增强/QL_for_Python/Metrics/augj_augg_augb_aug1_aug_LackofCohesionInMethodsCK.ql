/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Computes the Chidamber-Kemerer Lack of Cohesion in Methods (LCOM) metric.
 *              This metric quantifies the degree of dissimilarity between methods in a class,
 *              where higher values suggest lower cohesion. Classes with high LCOM scores
 *              may benefit from refactoring to improve design quality and maintainability.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Identify classes and compute their LCOM metric to evaluate method cohesion
// Results are sorted by descending LCOM scores to prioritize classes with poor cohesion
from ClassMetrics evaluatedClass
select evaluatedClass,
       evaluatedClass.getLackOfCohesionCK() as cohesionValue
order by cohesionValue desc