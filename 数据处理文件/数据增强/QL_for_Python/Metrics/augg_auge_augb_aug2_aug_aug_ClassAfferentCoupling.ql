/**
 * @name Class Dependency Inflow Analysis
 * @description Analyzes and quantifies the afferent coupling (dependency inflow) for each class in the codebase.
 *              Afferent coupling measures the number of other classes that depend on a given class, making it
 *              a crucial metric for understanding architectural importance. Classes with high afferent coupling
 *              are typically central components that require careful modification due to their potential
 *              ripple effects throughout the system. This analysis helps identify architectural hotspots
 *              and supports decision-making during refactoring and maintenance activities.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics analyzedClass
where 
  exists(analyzedClass.getAfferentCoupling())
select 
  analyzedClass,
  analyzedClass.getAfferentCoupling() as afferentCouplingMetric
order by 
  afferentCouplingMetric desc