/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes returned by `__iter__` methods that fail to implement the iterator protocol.
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

from ClassValue enclosingClass, FunctionValue iterMethod, ClassValue returnedType
where
  // Identify the __iter__ method within a container class
  iterMethod = enclosingClass.lookup("__iter__")
  and
  // Retrieve the inferred return type of the __iter__ method
  returnedType = iterMethod.getAnInferredReturnType()
  and
  // Validate that the return type lacks iterator protocol implementation
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()