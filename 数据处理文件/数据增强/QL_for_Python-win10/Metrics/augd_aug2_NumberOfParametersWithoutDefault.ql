/**
 * @name Number of parameters without defaults
 * @description This query calculates the number of function parameters that do not have default values.
 *              Functions with numerous parameters lacking default values can be challenging to test
 *              and comprehend, which might suggest underlying design problems.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python library for source code analysis

// This query identifies functions and counts their parameters without default values
from FunctionMetrics funcMetric
select 
    funcMetric, 
    funcMetric.getNumberOfParametersWithoutDefault() as paramCount 
order by paramCount desc
// Results are displayed with functions sorted by the count of parameters without defaults, in descending order