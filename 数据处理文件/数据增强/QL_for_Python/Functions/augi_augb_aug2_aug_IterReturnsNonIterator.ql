/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes returned by `__iter__` methods that don't implement the iterator protocol.
 *              Such classes will raise a 'TypeError' when used in iteration contexts like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iteratorMethod, ClassValue nonIteratorType
where
  // Locate the __iter__ method within a container class
  iteratorMethod = containerClass.lookup("__iter__")
  and
  // Obtain the inferred return type of the __iter__ method
  nonIteratorType = iteratorMethod.getAnInferredReturnType()
  and
  // Verify the return type lacks iterator protocol implementation
  not nonIteratorType.isIterator()
select nonIteratorType,
  "Class " + nonIteratorType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iteratorMethod, iteratorMethod.getName()