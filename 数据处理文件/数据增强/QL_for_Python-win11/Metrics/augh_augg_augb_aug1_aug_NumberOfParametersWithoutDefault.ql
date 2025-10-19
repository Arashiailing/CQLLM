/**
 * @name Non-default parameter count analysis
 * @description This analysis identifies functions with parameters lacking default values,
 *              providing insights into function complexity and potential testing difficulties.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Enables static analysis capabilities for Python code

// Define the source: all functions that have metrics available for evaluation
from FunctionMetrics targetFunction

// Extract the count of parameters that don't have default values assigned
where exists(targetFunction.getNumberOfParametersWithoutDefault())

// Select the function and its count of non-default parameters
select targetFunction, 
       targetFunction.getNumberOfParametersWithoutDefault() as mandatoryParamCount

// Order results to prioritize functions with higher numbers of mandatory parameters
order by mandatoryParamCount desc