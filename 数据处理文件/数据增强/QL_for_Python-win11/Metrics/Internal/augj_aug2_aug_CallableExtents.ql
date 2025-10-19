/**
 * @name Callable entities in Python code
 * @description Identifies all callable entities (functions and methods) 
 *              across Python codebases, providing their source locations.
 * @kind extent
 * @id py/callable-extents
 * @metricType callable
 */

import python

from Function callableEntity
select callableEntity.getLocation(), callableEntity