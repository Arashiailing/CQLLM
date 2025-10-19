/**
 * @name Extents of callables
 * @description Identifies all callable functions in Python code
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// Import the Python analysis library to access code elements
import python

// Define the query scope: all Python function objects
from Function callableFunction

// Output the source code location and the function object for each function
select callableFunction.getLocation(), callableFunction