/**
 * @name Count of non-default parameters
 * @description This analysis determines how many parameters in each function
 *              are not assigned default values, indicating mandatory inputs.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Importing the Python module to enable static analysis on Python source code

// Extract functions and calculate their non-default parameter count
from FunctionMetrics targetFunction
select targetFunction, 
       targetFunction.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
// Sort the results in descending order based on non-default parameter count
order by nonDefaultParamCount desc