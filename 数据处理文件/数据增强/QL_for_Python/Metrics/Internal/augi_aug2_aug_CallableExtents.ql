/**
 * @name Callable entity detection
 * @description Discovers all callable entities within Python codebase (functions and methods)
 * @kind extent
 * @id py/callable-extents
 * @metricType callable
 */

import python

from Function callableEntity
select 
    callableEntity.getLocation(), 
    callableEntity