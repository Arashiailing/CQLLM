/**
 * @name Class Dependency Inward Analysis
 * @description Computes and presents the quantity of classes that depend on each analyzed class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Analysis of class afferent coupling: Identifies and calculates the number of classes that depend on each target class
from ClassMetrics targetClass
where exists(targetClass.getAfferentCoupling())
select targetClass, 
       targetClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc