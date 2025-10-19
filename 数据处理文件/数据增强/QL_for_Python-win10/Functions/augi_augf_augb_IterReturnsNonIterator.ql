/**
 * @name `__iter__` method returns non-iterator type
 * @description Detects classes that are returned by `__iter__` methods but do not properly 
 *              implement the iterator protocol. This leads to runtime TypeErrors when these
 *              objects are used in iteration contexts such as for-loops or list comprehensions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue iteratedClass, FunctionValue iterMethod, ClassValue returnedType
where
  // Identify classes that define the __iter__ method
  iterMethod = iteratedClass.lookup("__iter__") and
  // Retrieve the type returned by the __iter__ method
  returnedType = iterMethod.getAnInferredReturnType() and
  // Verify that the returned type does not conform to iterator protocol
  not returnedType.isIterator()
select 
  returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but doesn't implement the iterator protocol.",
  iterMethod, iterMethod.getName()