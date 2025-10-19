/**
 * @name Class Dependency Inflow Analysis
 * @description Analyzes and quantifies the number of external classes that depend on each target class.
 *              Higher counts indicate classes with substantial incoming dependencies, which can impact
 *              system modularity and changeability.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract classes that have quantifiable incoming dependencies
from ClassMetrics examinedClass, int dependencyInflowCount
// Calculate the afferent coupling (incoming dependencies) for each examined class
where dependencyInflowCount = examinedClass.getAfferentCoupling()
// Ensure the dependency count exists (is not null/undefined)
  and exists(dependencyInflowCount)
// Output each class along with its dependency count, sorted in descending order
select examinedClass, 
       dependencyInflowCount 
order by dependencyInflowCount desc