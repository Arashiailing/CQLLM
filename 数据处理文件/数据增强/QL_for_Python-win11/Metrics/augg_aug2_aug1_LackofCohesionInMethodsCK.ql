/**
 * @name Method Cohesion Deficiency (CK Metric)
 * @description Identifies classes with poor method cohesion using Chidamber and Kemerer's metric.
 *              Higher values indicate greater cohesion deficiency within the class structure.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Analyze Python classes to determine their method cohesion deficiency
// The Chidamber-Kemerer metric quantifies cohesion, where elevated values suggest poorer design
from ClassMetrics analyzedClass
select analyzedClass, 
       analyzedClass.getLackOfCohesionCK() as cohesionMetric 
order by cohesionMetric desc