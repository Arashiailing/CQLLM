/**
 * @name Class Dependency Inflow Analysis
 * @description This query determines the number of classes that depend on each target class (afferent coupling).
 *              It serves as a modularity assessment tool by highlighting classes with high incoming dependencies.
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
where exists(analyzedClass.getAfferentCoupling())
select 
  analyzedClass,
  analyzedClass.getAfferentCoupling() as incomingDependencies
order by incomingDependencies desc