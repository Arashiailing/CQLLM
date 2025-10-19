/**
 * @name Class dependency impact analysis
 * @description This analysis measures the afferent coupling of classes,
 *              which represents the count of external classes that depend on a specific class.
 *              Classes with higher afferent coupling values are considered more
 *              architecturally significant and changes to them may have broader impact.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Define the main analysis query for class coupling
from ClassMetrics targetClass, int couplingCount
where 
  // Calculate the afferent coupling for each class
  couplingCount = targetClass.getAfferentCoupling() and
  // Ensure the coupling count exists and is measurable
  exists(couplingCount)
select 
  targetClass, 
  couplingCount 
order by 
  couplingCount desc