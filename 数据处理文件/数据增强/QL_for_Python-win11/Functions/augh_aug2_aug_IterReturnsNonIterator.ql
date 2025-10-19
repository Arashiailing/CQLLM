/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes returned by `__iter__` methods that don't implement 
 *              the iterator protocol, which would cause 'TypeError' in iteration contexts.
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
  // Identify the __iter__ method within its containing class
  iterMethod = enclosingClass.lookup("__iter__")
  and
  // Extract the inferred return type of the __iter__ method
  returnedType = iterMethod.getAnInferredReturnType()
  and
  // Ensure the return type lacks proper iterator implementation
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()