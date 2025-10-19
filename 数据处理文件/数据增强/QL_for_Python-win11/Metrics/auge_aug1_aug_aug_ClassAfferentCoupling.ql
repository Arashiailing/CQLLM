/**
 * @name Analysis of incoming class dependencies
 * @description This query calculates the afferent coupling for each class,
 *              which represents the number of other classes that depend on it.
 *              Higher values indicate classes that are more central to the codebase.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes and compute their incoming dependency count
// Afferent coupling measures how many other classes depend on a given class
from ClassMetrics subjectClass, int inboundCoupling
where 
  // Calculate the afferent coupling (incoming dependencies) for the class
  inboundCoupling = subjectClass.getAfferentCoupling() and 
  // Ensure the coupling count exists (non-null and valid)
  exists(inboundCoupling)
select subjectClass, 
       inboundCoupling as dependencyCount 
order by dependencyCount desc