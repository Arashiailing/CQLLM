/**
 * @name Number of parameters without defaults
 * @description Calculates the count of function parameters that lack default values.
 *              Functions with many parameters without defaults may be harder to test
 *              and understand, potentially indicating a design issue.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python library for analyzing Python source code

// Query to analyze functions and count their parameters without default values
from FunctionMetrics functionObj
select 
    functionObj, 
    functionObj.getNumberOfParametersWithoutDefault() as paramCount 
order by paramCount desc
// Display functions sorted by the count of parameters without default values in descending order