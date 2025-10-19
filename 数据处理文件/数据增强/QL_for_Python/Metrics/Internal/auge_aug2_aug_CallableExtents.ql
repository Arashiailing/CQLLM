/**
 * @name Callable Entity Extents
 * @description Identifies all callable entities (functions/methods) in Python code
 * @kind extent
 * @id py/callable-extents
 * @metricType callable
 */

import python

from Function callableEntity
select callableEntity.getLocation(), callableEntity