/**
 * @name Lack of Cohesion in Methods (CK)
 * @description This query computes the Lack of Cohesion in Methods (LCOM) metric 
 *              as defined by Chidamber and Kemerer. The metric measures the degree
 *              of dissimilarity between methods in a class, where higher values
 *              indicate lower cohesion and potentially a need for refactoring.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Define the source of classes to be analyzed
from ClassMetrics evaluatedClass

// For each evaluated class, compute its LCOM metric
// and sort results in descending order to highlight classes
// with the lowest cohesion (highest LCOM values)
select evaluatedClass, 
       evaluatedClass.getLackOfCohesionCK() as lcomScore 
order by lcomScore desc