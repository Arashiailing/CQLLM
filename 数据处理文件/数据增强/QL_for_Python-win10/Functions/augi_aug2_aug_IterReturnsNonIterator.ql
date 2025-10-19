/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes returned by `__iter__` methods that don't implement the iterator protocol.
 *              Such classes cause 'TypeError' when used in iteration contexts like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue enclosingClass, FunctionValue iterMethod, ClassValue iterReturnType
where
  // Identify the __iter__ method in a container class
  iterMethod = enclosingClass.lookup("__iter__")
  and
  // Retrieve the inferred return type of the __iter__ method
  iterReturnType = iterMethod.getAnInferredReturnType()
  and
  // Verify the return type lacks iterator implementation
  not iterReturnType.isIterator()
select iterReturnType,
  "Class " + iterReturnType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()