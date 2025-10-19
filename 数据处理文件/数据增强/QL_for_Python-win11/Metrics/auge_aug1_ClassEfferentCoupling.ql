/**
 * @name External class dependencies analysis
 * @description Quantifies the number of distinct external classes that a particular class depends on.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// This query calculates the efferent coupling count for each class, which represents
// how many different classes a given class depends on. Results are sorted in descending
// order to highlight classes with high coupling, indicating potential design issues.

from ClassMetrics analyzedClass
select analyzedClass, analyzedClass.getEfferentCoupling() as dependencyCount 
order by dependencyCount desc