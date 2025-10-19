/**
 * @name `__iter__` method returns non-iterator type
 * @description Identifies classes that are returned by `__iter__` methods but fail to implement 
 *              the iterator protocol. Such classes would cause TypeError when used in iteration
 *              contexts like for-loops or comprehensions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue sourceClass, FunctionValue iteratorMethod, ClassValue resultType
where
  // Find classes defining the __iter__ method
  iteratorMethod = sourceClass.lookup("__iter__") and
  // Extract the return type of the __iter__ method
  resultType = iteratorMethod.getAnInferredReturnType() and
  // Ensure the return type doesn't conform to iterator protocol
  not resultType.isIterator()
select 
  resultType,
  "Class " + resultType.getName() + 
    " is returned as an iterator (by $@) but doesn't implement the iterator protocol.",
  iteratorMethod, iteratorMethod.getName()