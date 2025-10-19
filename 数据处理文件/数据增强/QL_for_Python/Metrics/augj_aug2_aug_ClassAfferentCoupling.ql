/**
 * @name Afferent class coupling analysis
 * @description Identifies and quantifies the number of classes that depend on each analyzed class,
 *              providing insight into the class's impact on the codebase.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract class metrics for analysis and retrieve the afferent coupling value
from ClassMetrics analyzedClass, int afferentCouplingValue
where 
  // Calculate the number of incoming dependencies to the analyzed class
  afferentCouplingValue = analyzedClass.getAfferentCoupling()
  // Ensure the coupling value exists (i.e., is not null)
  and exists(afferentCouplingValue)
select analyzedClass, 
       afferentCouplingValue as dependencyCount 
order by dependencyCount desc