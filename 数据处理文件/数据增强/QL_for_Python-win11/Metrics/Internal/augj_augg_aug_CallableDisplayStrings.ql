/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 */

// Import Python language module for code structure analysis
import python

// Define query scope: select all Python function definitions
from Function pyFunction
// Produce output: function entity with descriptive string representation
select pyFunction, "Function " + pyFunction.getName()