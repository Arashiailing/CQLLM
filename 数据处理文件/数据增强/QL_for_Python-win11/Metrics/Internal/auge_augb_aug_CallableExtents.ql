/**
 * @description Identifies and enumerates all callable functions in Python codebase
 * @kind metrics
 * @id py/callable-extents
 * @metricType function
 */

// Import the foundational Python analysis library to access code elements
import python

// Define the scope of analysis: all Python callable functions
from Function callableObj

// Output source location and the function object for each identified callable
select callableObj.getLocation(), callableObj