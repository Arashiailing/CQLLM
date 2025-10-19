/**
 * @name Class Dependency Analysis
 * @description Calculates the number of classes that depend on each class in the codebase.
 *              This metric, known as afferent coupling, helps identify central components
 *              that are heavily relied upon by other parts of the system. Classes with high
 *              afferent coupling should be modified with caution as changes can have widespread
 *              effects, potentially impacting system stability and maintainability.
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