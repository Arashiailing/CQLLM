/**
 * @name Extents of callables
 * @description Identifies all callable entities in Python code (functions/methods)
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

import python

from Function func
select func.getLocation(), func