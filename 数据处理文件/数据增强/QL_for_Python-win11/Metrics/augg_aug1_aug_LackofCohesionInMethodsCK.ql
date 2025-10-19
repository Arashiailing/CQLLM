/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Computes the Lack of Cohesion in Methods (LCOM) metric as defined by 
 *              Chidamber and Kemerer. This metric quantifies the dissimilarity among 
 *              methods in a class. Higher LCOM values suggest lower cohesion, indicating 
 *              potential refactoring opportunities.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// The source of classes for analysis
from ClassMetrics cls

// For each class, compute the LCOM metric
// and sort in descending order to highlight classes with the lowest cohesion
select cls, 
       cls.getLackOfCohesionCK() as lcomScore 
order by lcomScore desc