/**
 * @name Analysis of Class Incoming Dependencies
 * @description This analysis measures the incoming coupling for each class, representing the number of other classes that depend on it.
 *              It serves as an indicator of modularity by highlighting classes that are heavily depended upon.
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
  analyzedClass.getAfferentCoupling() as incomingCoupling
order by incomingCoupling desc