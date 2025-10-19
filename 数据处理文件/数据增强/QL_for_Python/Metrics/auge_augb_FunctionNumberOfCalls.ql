/**
 * @name Function call count analysis
 * @description Measures the total quantity of function invocations within each Python function.
 *              This metric helps identify potentially complex functions that might benefit
 *              from refactoring or further investigation.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Import Python library for analyzing Python code

// Retrieve function metrics for all Python functions in the codebase
from FunctionMetrics funcMetrics
// Select each function along with its call count, sorted by call count in descending order
select funcMetrics, funcMetrics.getNumberOfCalls() as callCount order by callCount desc