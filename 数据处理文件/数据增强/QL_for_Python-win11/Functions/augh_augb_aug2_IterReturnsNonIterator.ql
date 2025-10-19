/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes where the `__iter__` method returns an object 
 *              that doesn't implement the iterator protocol. Such classes would 
 *              cause a 'TypeError' when used in iteration contexts like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue definingClass, FunctionValue iterMethod, ClassValue returnType
where
  // Locate classes implementing the __iter__ method
  iterMethod = definingClass.lookup("__iter__") and
  
  // Determine the inferred return type of the __iter__ method
  returnType = iterMethod.getAnInferredReturnType() and
  
  // Confirm the return type fails to implement iterator protocol
  not returnType.isIterator()
select returnType,
  "Class " + returnType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()