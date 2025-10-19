/**
 * @name Method Cohesion Deficiency (CK Metric)
 * @description Detects classes with poor method cohesion using Chidamber and Kemerer's metric.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Identify all Python classes and evaluate their method cohesion deficiency
// Higher values indicate poorer cohesion according to Chidamber-Kemerer metric
from ClassMetrics targetClass
select targetClass, targetClass.getLackOfCohesionCK() as cohesionMetric order by cohesionMetric desc