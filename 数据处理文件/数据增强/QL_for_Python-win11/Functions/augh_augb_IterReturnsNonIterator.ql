/**
 * @name `__iter__` method returns non-iterator type
 * @description Identifies classes returned by `__iter__` methods that fail to implement 
 *              the iterator protocol, causing TypeError in iteration contexts like for-loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue sourceClass, FunctionValue iterMethod, ClassValue returnType
where
  // Locate the __iter__ method within the iterable class
  iterMethod = sourceClass.lookup("__iter__") and
  // Derive the inferred return type of the __iter__ method
  returnType = iterMethod.getAnInferredReturnType() and
  // Confirm the return type violates iterator protocol requirements
  not returnType.isIterator()
select 
  returnType,
  "Class " + returnType.getName() + 
    " is returned as an iterator (by $@) but doesn't implement the iterator protocol.",
  iterMethod, iterMethod.getName()