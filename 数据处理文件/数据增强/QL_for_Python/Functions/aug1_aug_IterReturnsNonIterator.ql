/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes that are returned by `__iter__` methods but fail to implement 
 *              the iterator interface. Such classes would trigger a 'TypeError' when used in 
 *              iteration contexts like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iteratorMethod, ClassValue iteratorReturnType
where
  // Identify classes that define an __iter__ method
  iteratorMethod = containerClass.lookup("__iter__") and
  // Determine the return type of the __iter__ method
  iteratorReturnType = iteratorMethod.getAnInferredReturnType() and
  // Verify that the return type is not a proper iterator
  not iteratorReturnType.isIterator()
select iteratorReturnType,
  "Class " + iteratorReturnType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iteratorMethod, iteratorMethod.getName()