/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes whose `__iter__` method returns objects that don't implement
 *              the iterator protocol. Such classes will raise TypeError when used in for-loops.
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
  // Locate classes defining the __iter__ method
  iterMethod = definingClass.lookup("__iter__") and
  
  // Extract the inferred return type of the __iter__ method
  returnType = iterMethod.getAnInferredReturnType() and
  
  // Verify the return type lacks iterator protocol implementation
  not returnType.isIterator()
select returnType,
  "Class " + returnType.getName() + 
    " is returned as an iterator (by $@) but fails to implement the iterator interface.",
  iterMethod, iterMethod.getName()