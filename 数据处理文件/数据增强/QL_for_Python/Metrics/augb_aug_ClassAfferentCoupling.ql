/**
 * @name Incoming class dependencies analysis
 * @description Quantifies the number of classes that depend on each target class, 
 *              providing insight into the class's centrality and potential impact radius.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with measurable incoming dependencies and extract their coupling count
from ClassMetrics cls, int couplingCount
where couplingCount = cls.getAfferentCoupling()
select cls, 
       couplingCount as dependencyCount 
order by dependencyCount desc