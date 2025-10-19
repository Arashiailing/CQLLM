/**
 * @name Display strings of callables
 * @kind display-string
 * @id py/function-display-strings
 * @metricType callable
 * @description Identifies and displays all Python function definitions with their names.
 *              This query helps in understanding the function landscape of a Python codebase.
 */

// Import the core Python analysis module for code inspection
import python

// Define the query scope: Identify all Python function definitions in the codebase
from Function pyFunction

// Construct and return an identification string for each function
// The output includes the function object and a descriptive string containing the function name
select 
    pyFunction, 
    "Function " + pyFunction.getName()