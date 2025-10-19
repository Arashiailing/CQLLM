/**
 * @name Number of parameters without defaults
 * @description This query analyzes Python functions to determine how many parameters 
 *              in each function do not have default values assigned. Functions with 
 *              many parameters without defaults may be harder to use and test.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python module for static code analysis

// Select all Python functions and calculate the count of their parameters without default values
from FunctionMetrics analyzedFunction
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as paramCountWithoutDefault 
// Order results in descending order based on the count of parameters without defaults
order by paramCountWithoutDefault desc