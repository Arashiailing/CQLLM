/**
 * @name Function Statement Nesting Depth Analysis
 * @description Measures and displays the deepest level of statement nesting within functions.
 *              Elevated nesting levels typically suggest higher complexity and diminished code maintainability.
 * @kind treemap
 * @id py/statement-nesting-depth-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags maintainability
 *       complexity
 */

import python

// Extract functions to be evaluated for statement nesting complexity
from FunctionMetrics evaluatedFunction
// Compute and present the nesting depth metric for each function, arranged from highest to lowest complexity
select evaluatedFunction, evaluatedFunction.getStatementNestingDepth() as depth order by depth desc