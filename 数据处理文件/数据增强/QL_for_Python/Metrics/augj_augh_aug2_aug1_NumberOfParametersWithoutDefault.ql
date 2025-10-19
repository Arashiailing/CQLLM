/**
 * @name Number of parameters without defaults
 * @description Analyzes Python functions to count parameters that lack default values,
 *              highlighting functions with many required parameters which may impact testability.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python analysis library to enable code processing capabilities

// Extract function statistics to determine the quantity of parameters without default values
from FunctionMetrics funcStats
select 
  funcStats, 
  funcStats.getNumberOfParametersWithoutDefault() as mandatoryParamCount 
order by 
  mandatoryParamCount desc
// Present functions along with their counts of parameters that require explicit values,
// sorted from highest to lowest to emphasize functions with the most required parameters