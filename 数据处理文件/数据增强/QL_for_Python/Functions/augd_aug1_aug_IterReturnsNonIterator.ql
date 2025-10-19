/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes that are returned by `__iter__` methods but do not properly 
 *              implement the iterator protocol. These classes will cause a 'TypeError' 
 *              when used in iteration contexts such as 'for' loops.
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
  // Find classes that implement the __iter__ method
  iterMethod = iterableClass.lookup("__iter__")
  and
  // Extract the return type from the __iter__ method
  returnedType = iterMethod.getAnInferredReturnType()
  and
  // Check if the returned type fails to implement the iterator interface
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()