/**
 * @name Number of parameters without defaults
 * @description Identifies functions and counts their parameters that do not have default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python analysis library to enable code processing capabilities

// Extract function metrics and determine the count of parameters without default values
from FunctionMetrics functionMetric
select 
  functionMetric, 
  functionMetric.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by 
  nonDefaultParamCount desc
// Display functions along with their respective counts of parameters lacking defaults,
// sorted in descending order to highlight functions with the most required parameters