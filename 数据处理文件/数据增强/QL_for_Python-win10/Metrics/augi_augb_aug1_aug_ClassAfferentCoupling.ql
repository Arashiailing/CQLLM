/**
 * @name Class Dependency Inflow Analysis
 * @description Quantifies the number of external classes that depend on each analyzed class.
 *              Higher values indicate classes with more incoming dependencies, impacting modularity.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with quantifiable incoming dependencies and their respective counts
from ClassMetrics analyzedClass, int afferentCouplingCount
where 
    // Calculate the afferent coupling (incoming dependencies) for each class
    afferentCouplingCount = analyzedClass.getAfferentCoupling() and
    // Ensure the coupling count exists and is measurable
    exists(afferentCouplingCount)
// Output each class along with its incoming dependency count, sorted in descending order
select analyzedClass, 
       afferentCouplingCount 
order by afferentCouplingCount desc