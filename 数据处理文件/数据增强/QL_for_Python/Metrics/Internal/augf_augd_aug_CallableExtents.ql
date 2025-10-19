/**
 * @name Extents of callables
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 * @description Identifies and reports all callable entities (functions and methods)
 *              in the Python codebase, providing their location information.
 *              This query serves as a foundational analysis for understanding
 *              the structure and distribution of callable components within
 *              the target Python project.
 */

// Import the Python analysis library to enable code examination
import python

// Define a variable representing all callable entities in the codebase
from Function callableEntity

// Select and report the location along with the callable entity
select callableEntity.getLocation(), callableEntity