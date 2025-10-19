/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes returned by `__iter__` methods that don't implement the iterator interface.
 *              Such classes would cause a 'TypeError' when used in iteration contexts like 'for' loops.
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
  // Locate the __iter__ method within a class
  iterMethod = iterableClass.lookup("__iter__") and
  // Determine the inferred return type of the __iter__ method
  returnedType = iterMethod.getAnInferredReturnType() and
  // Verify the returned type doesn't implement the iterator interface
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()