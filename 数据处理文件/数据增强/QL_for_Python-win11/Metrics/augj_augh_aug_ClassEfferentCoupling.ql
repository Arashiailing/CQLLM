/**
 * @name Class Efferent Coupling Analysis
 * @description Measures and quantifies the number of distinct external classes that each class depends on.
 *              Efferent coupling represents how many different types a particular class relies upon,
 *              which is a key indicator of class responsibility and modularity.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// Analyze each class in the codebase to determine its efferent coupling
// Efferent coupling is calculated as the count of distinct external dependencies
from ClassMetrics analyzedClass
// Calculate the efferent coupling metric for the analyzed class
select analyzedClass, 
       analyzedClass.getEfferentCoupling() as efferentCouplingCount 
// Order results by the efferent coupling count in descending order
// This highlights classes with the highest number of external dependencies first
order by efferentCouplingCount desc