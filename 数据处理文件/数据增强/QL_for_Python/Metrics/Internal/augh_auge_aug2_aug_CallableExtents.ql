/**
 * @name Python Callable Functions and Methods
 * @description Identifies all callable functions and methods present in Python source code
 * @kind extent
 * @id py/callable-extents
 * @metricType callable
 */

import python

from Function callableFunction
select callableFunction.getLocation(), callableFunction