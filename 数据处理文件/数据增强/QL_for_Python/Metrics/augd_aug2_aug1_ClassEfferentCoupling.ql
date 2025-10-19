/**
 * @name Outgoing class dependencies
 * @description Calculates the number of external dependencies for each class.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// This query analyzes efferent coupling (outgoing dependencies) for Python classes.
// Efferent coupling measures how many external classes a given class depends on.
// Classes with high efferent coupling may be harder to test and maintain,
// as they have many dependencies on external components.

// Main analysis: extract class metrics and calculate efferent coupling
from ClassMetrics cls
where 
    // Filter to ensure we only analyze valid classes with non-negative coupling
    cls.getEfferentCoupling() >= 0
select 
    cls, 
    cls.getEfferentCoupling() as outgoingDeps 
order by 
    outgoingDeps desc