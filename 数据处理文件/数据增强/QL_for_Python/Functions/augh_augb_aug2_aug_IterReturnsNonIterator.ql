/**
 * @name `__iter__` method returns non-iterator type
 * @description Detects classes that are returned by `__iter__` methods but do not properly implement the iterator protocol.
 *              These classes will cause a 'TypeError' when used in iteration constructs such as 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iteratorMethod, ClassValue resultType
where
  // Locate the __iter__ method within a container class
  iteratorMethod = containerClass.lookup("__iter__")
  and
  // Obtain the inferred return type of the __iter__ method
  resultType = iteratorMethod.getAnInferredReturnType()
  and
  // Verify that the return type does not implement the iterator protocol
  not resultType.isIterator()
select resultType,
  "Class " + resultType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iteratorMethod, iteratorMethod.getName()