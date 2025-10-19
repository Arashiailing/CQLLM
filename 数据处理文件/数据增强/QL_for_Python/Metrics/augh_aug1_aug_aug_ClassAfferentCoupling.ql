/**
 * @name Evaluation of class incoming dependencies
 * @description This query determines the afferent coupling metric for every class,
 *              indicating how many other classes rely on it.
 *              Elevated values suggest classes with greater significance in the codebase.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with quantifiable incoming dependencies and their count
from ClassMetrics examinedClass, int dependencyNumber
where exists(dependencyNumber) and 
      dependencyNumber = examinedClass.getAfferentCoupling()
select examinedClass, 
       dependencyNumber as dependencyCount 
order by dependencyCount desc