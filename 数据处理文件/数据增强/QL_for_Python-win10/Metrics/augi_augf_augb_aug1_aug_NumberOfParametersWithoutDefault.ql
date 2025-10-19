/**
 * @name Mandatory parameter count analysis
 * @description Identifies functions with numerous parameters lacking default values,
 *              which may indicate higher complexity and mandatory input requirements.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Importing the Python module to enable static analysis on Python source code

// Define the source of functions to analyze
from FunctionMetrics analyzedFunction

// Calculate the count of parameters without default values for each function
where exists(analyzedFunction.getNumberOfParametersWithoutDefault())

// Select the function and its non-default parameter count
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as mandatoryParamCount 

// Order results by the count of mandatory parameters in descending order
order by mandatoryParamCount desc