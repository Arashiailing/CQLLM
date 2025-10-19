/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Detects classes with poor method cohesion using Chidamber and Kemerer's LCOM metric.
 *              Higher scores indicate lower cohesion, suggesting potential refactoring opportunities.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Analyze all Python classes to compute the Lack of Cohesion in Methods (LCOM)
// Based on Chidamber-Kemerer metric, where higher values indicate weaker cohesion
from ClassMetrics analyzedClass
select analyzedClass, analyzedClass.getLackOfCohesionCK() as lcomScore order by lcomScore desc