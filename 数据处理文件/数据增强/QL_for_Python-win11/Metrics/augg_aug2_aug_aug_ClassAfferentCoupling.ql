/**
 * @name Class Afferent Coupling Analysis
 * @description Quantifies the number of classes that have dependencies on each analyzed class.
 *              This metric helps identify architectural hotspots where changes might have
 *              widespread impact across the codebase.
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
  analyzedClass.getAfferentCoupling() as couplingCount
order by couplingCount desc