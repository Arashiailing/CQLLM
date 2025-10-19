/**
 * @name Extents of callables
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 * @description Identifies and reports all callable entities (functions and methods)
 *              in the Python codebase, providing their location information.
 */

// Import the Python analysis library to enable code examination
import python

// Query to find all callable entities and their locations
from Function func
select func.getLocation(), func