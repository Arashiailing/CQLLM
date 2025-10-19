/**
 * @name Number of parameters without defaults
 * @description Measures the quantity of function parameters that do not have default values assigned.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python analysis library to enable processing of Python code

// Retrieve function metrics to analyze parameter characteristics
from FunctionMetrics functionStats

// Calculate and display the count of parameters lacking default values for each function
select 
  functionStats, 
  functionStats.getNumberOfParametersWithoutDefault() as mandatoryParamCount 

// Sort results in descending order based on the number of non-default parameters
order by 
  mandatoryParamCount desc