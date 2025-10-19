/**
 * @name Number of parameters without defaults
 * @description Identifies functions with parameters lacking default values.
 *              Functions containing numerous parameters without defaults may
 *              present challenges in testing and comprehension, potentially
 *              indicating design flaws that warrant attention.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python library for analyzing Python source code

// Identify functions and quantify parameters without default values
from FunctionMetrics analyzedFunction
select 
    analyzedFunction, 
    analyzedFunction.getNumberOfParametersWithoutDefault() as paramCount 
order by paramCount desc
// Results sorted by parameter count to highlight functions requiring most attention