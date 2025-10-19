/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Implements the Chidamber-Kemerer Lack of Cohesion in Methods metric.
 *              This analysis identifies classes where methods exhibit low correlation,
 *              which may indicate poor design and potential refactoring candidates.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// Data source definition: classes available for metrics evaluation
from ClassMetrics targetClass

// Metric calculation and result presentation:
// 1. Compute the Lack of Cohesion value for each target class
// 2. Assign the result to 'cohesionScore' for clear reference
// 3. Sort results in descending order to highlight classes with lowest cohesion first
select targetClass, targetClass.getLackOfCohesionCK() as cohesionScore order by cohesionScore desc