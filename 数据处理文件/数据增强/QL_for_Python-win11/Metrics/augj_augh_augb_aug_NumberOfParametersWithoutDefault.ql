/**
 * @name Number of parameters without defaults
 * @description This analysis identifies Python functions with parameters lacking default values.
 *              Functions with many non-default parameters tend to be more complex and harder to test,
 *              as they require more arguments to be explicitly provided during invocation.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python module for static code analysis capabilities

// Define the analysis scope: examine all Python functions to evaluate their parameter complexity
from FunctionMetrics targetFunction
// Calculate the count of parameters without default values for each function
where exists(targetFunction.getNumberOfParametersWithoutDefault())
// Select the target function and its count of non-default parameters for complexity assessment
select targetFunction, 
       targetFunction.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
// Order results by non-default parameter count in descending order to highlight most complex functions first
order by nonDefaultParamCount desc