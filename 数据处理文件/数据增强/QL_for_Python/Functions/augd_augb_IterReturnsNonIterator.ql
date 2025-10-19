/**
 * @name `__iter__` method returns non-iterator type
 * @description Identifies classes returned by `__iter__` methods that fail to implement 
 *              the iterator protocol, which would trigger TypeErrors in iteration contexts
 *              such as for-loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iteratorMethod, ClassValue returnType
where
  // Locate the __iter__ method within the container class
  iteratorMethod = containerClass.lookup("__iter__") and
  // Extract the inferred return type from the __iter__ method
  returnType = iteratorMethod.getAnInferredReturnType() and
  // Confirm the return type violates iterator protocol requirements
  not returnType.isIterator()
select 
  returnType,
  "Class " + returnType.getName() + 
    " is returned as an iterator (by $@) but doesn't implement the iterator protocol.",
  iteratorMethod, iteratorMethod.getName()