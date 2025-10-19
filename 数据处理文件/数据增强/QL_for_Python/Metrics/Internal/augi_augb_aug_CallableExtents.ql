/**
 * @name Extents of callables
 * @description Provides a comprehensive view of all callable functions in Python code,
 *              mapping each function to its source location for analysis purposes.
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// Import the essential Python analysis library for code element access and examination
import python

// Define the analysis scope: target all Python function definitions within the codebase
from Function callableEntity

// Retrieve and present the source location alongside each callable function entity
select callableEntity.getLocation(), callableEntity