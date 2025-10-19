/**
 * @name `__iter__` method returns non-iterator type
 * @description Identifies classes returned by `__iter__` methods that fail to implement the iterator protocol,
 *              which would trigger TypeError in iteration contexts such as for-loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue sourceClass, FunctionValue iterFunc, ClassValue resultType
where
  // Locate the __iter__ method within the source class
  iterFunc = sourceClass.lookup("__iter__") and
  // Extract the inferred return type from the __iter__ method
  resultType = iterFunc.getAnInferredReturnType() and
  // Validate that the returned type lacks iterator protocol implementation
  not resultType.isIterator()
select 
  resultType,
  "Class " + resultType.getName() + 
    " is returned as an iterator (by $@) but fails to implement the iterator protocol.",
  iterFunc, iterFunc.getName()