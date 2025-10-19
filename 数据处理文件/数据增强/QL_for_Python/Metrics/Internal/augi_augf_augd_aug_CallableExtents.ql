/**
 * @name Extents of callables
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 * @description Discovers and enumerates all callable elements (functions and methods)
 *              present in the analyzed Python codebase, along with their source locations.
 *              This analysis provides a comprehensive overview of the callable components
 *              distribution, serving as a basis for further structural analysis and
 *              understanding of the Python project under examination.
 */

// Import the necessary Python analysis module for code examination
import python

// Query all callable elements (functions and methods) in the codebase
from Function functionOrMethod

// Output the source location and the callable element itself
select functionOrMethod.getLocation(), functionOrMethod