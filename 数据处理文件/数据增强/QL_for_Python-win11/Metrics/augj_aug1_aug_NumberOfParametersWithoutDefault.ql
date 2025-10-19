/**
 * @name Count of non-default parameters
 * @description This query analyzes Python functions to determine the count of parameters 
 *              that do not have default value assignments. Functions with a higher number 
 *              of such parameters may be less flexible and harder to test.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python module to enable static analysis of Python code

// Define the source of our analysis: all Python functions with metrics
from FunctionMetrics analyzedFunction

// Select the function and its count of parameters without default values
// Order the results in descending order to highlight functions with the most mandatory parameters
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as mandatoryParamCount 
order by mandatoryParamCount desc