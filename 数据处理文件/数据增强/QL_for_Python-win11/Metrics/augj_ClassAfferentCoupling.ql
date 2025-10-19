/**
 * @name Class dependency analysis
 * @description Measures how many other classes depend on each class in the codebase.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// For each class in the codebase, retrieve its metric information
// and calculate the number of classes that depend on it (afferent coupling)
from ClassMetrics targetClass
select targetClass, targetClass.getAfferentCoupling() as couplingCount order by couplingCount desc