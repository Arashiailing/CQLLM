/**
 * @name Class Afferent Coupling Analysis
 * @description Measures the afferent coupling (number of external classes that depend on) each class.
 *              Classes with high afferent coupling are more central in the dependency graph, making them
 *              harder to change without affecting other parts of the system, thus reducing modularity.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes and calculate their inbound dependency count
from ClassMetrics analyzedClass, int inboundCount 
where 
  // Compute afferent coupling (external dependencies) for each class
  inboundCount = analyzedClass.getAfferentCoupling() and
  // Ensure the dependency count is a measurable value
  inboundCount >= 0  // Implicitly filters null values since null >= 0 is false

// Output classes sorted by dependency count (highest first)
select analyzedClass, 
       inboundCount 
order by inboundCount desc