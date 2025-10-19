/**
 * @name Callable Entity Extents
 * @description Finds all functions and methods (callable entities) in Python source code
 * @kind extent
 * @id py/callable-extents
 * @metricType callable
 */

import python

from Function callableFunc
select 
  callableFunc.getLocation(), 
  callableFunc