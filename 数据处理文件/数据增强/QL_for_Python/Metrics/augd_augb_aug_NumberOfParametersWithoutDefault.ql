/**
 * @name Number of parameters without defaults
 * @description Measures the count of parameters in Python functions that do not have default values, which can indicate increased complexity.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python module to enable static analysis of Python code

// Examine all Python functions to determine the number of parameters without default values
from FunctionMetrics analyzedFunction
// Calculate the count of mandatory parameters (those without default values) for each function
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
// Sort in descending order by the count of non-default parameters to highlight functions with higher complexity
order by nonDefaultParamCount desc