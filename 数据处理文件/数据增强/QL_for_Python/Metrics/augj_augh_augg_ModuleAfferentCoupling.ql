/**
 * @name Module Afferent Coupling Analysis
 * @description Measures afferent coupling for each module, indicating the count
 *              of external dependencies. Higher values signify architectural criticality
 *              and increased maintenance complexity.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Identify modules and quantify their incoming dependencies
from ModuleMetrics moduleData
// Output modules with dependency counts in descending order
select 
    moduleData, 
    moduleData.getAfferentCoupling() as incomingDeps 
order by 
    incomingDeps desc