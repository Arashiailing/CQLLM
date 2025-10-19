/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes returned by `__iter__` methods that fail to implement 
 *              the iterator protocol, leading to 'TypeError' in iteration contexts.
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
  // Locate the __iter__ method within its defining class
  iteratorMethod = containerClass.lookup("__iter__")
  and
  // Retrieve the inferred return type of the __iter__ method
  resultType = iteratorMethod.getAnInferredReturnType()
  and
  // Verify the return type lacks proper iterator implementation
  not resultType.isIterator()
select resultType,
  "Class " + resultType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iteratorMethod, iteratorMethod.getName()