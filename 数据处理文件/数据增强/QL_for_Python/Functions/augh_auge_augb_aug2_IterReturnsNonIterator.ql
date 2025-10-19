/**
 * @name `__iter__` method returns non-iterator object
 * @description Detects classes whose `__iter__` method returns objects that don't implement
 *              the iterator protocol. This causes TypeError when used in for-loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iterMethodDef, ClassValue returnedType
where
  // Find classes that implement the __iter__ method
  iterMethodDef = containerClass.lookup("__iter__") and
  
  // Obtain the inferred return type of the __iter__ method
  returnedType = iterMethodDef.getAnInferredReturnType() and
  
  // Verify the return type lacks iterator protocol implementation
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but fails to implement the iterator interface.",
  iterMethodDef, iterMethodDef.getName()