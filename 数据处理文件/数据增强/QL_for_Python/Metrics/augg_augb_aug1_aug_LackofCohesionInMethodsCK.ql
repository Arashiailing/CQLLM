/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Computes the Chidamber-Kemerer Lack of Cohesion in Methods (LCOM) metric.
 *              This metric assesses the dissimilarity between methods within a class;
 *              higher values indicate lower cohesion and may signal refactoring needs.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Select classes for cohesion analysis and calculate their LCOM scores
// Results are ordered by descending LCOM values to highlight classes with poor cohesion first
from ClassMetrics analyzedClass
select analyzedClass,
       analyzedClass.getLackOfCohesionCK() as cohesionMetric
order by cohesionMetric desc