/**
 * @name Number of parameters without defaults
 * @description This query computes the quantity of function parameters that do not have default values specified.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python module for static code analysis capabilities

// Query to analyze Python functions and determine the count of their parameters without default values
from FunctionMetrics funcMetrics
// Select each function along with its count of parameters without defaults, sorted in descending order
select funcMetrics, 
       funcMetrics.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by nonDefaultParamCount desc