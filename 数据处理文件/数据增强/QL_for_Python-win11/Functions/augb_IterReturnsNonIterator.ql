/**
 * @name `__iter__` method returns non-iterator type
 * @description Detects classes returned by `__iter__` methods that don't implement the iterator protocol,
 *              which would cause TypeError when used in iteration contexts like for-loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue iterableClass, FunctionValue iterMethod, ClassValue returnedType
where
  // Identify the __iter__ method in the iterable class
  iterMethod = iterableClass.lookup("__iter__") and
  // Obtain the inferred return type of the __iter__ method
  returnedType = iterMethod.getAnInferredReturnType() and
  // Verify the returned type doesn't satisfy iterator requirements
  not returnedType.isIterator()
select 
  returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but doesn't implement the iterator protocol.",
  iterMethod, iterMethod.getName()