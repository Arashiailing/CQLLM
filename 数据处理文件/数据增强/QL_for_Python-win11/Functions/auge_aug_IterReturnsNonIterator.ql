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

from ClassValue sourceClass, FunctionValue iterMethodDef, ClassValue iterReturnType
where
  // Identify classes defining the __iter__ method
  iterMethodDef = sourceClass.lookup("__iter__")
  and
  // Extract the inferred return type of the __iter__ method
  iterReturnType = iterMethodDef.getAnInferredReturnType()
  and
  // Verify the return type fails to implement iterator interface
  not iterReturnType.isIterator()
select iterReturnType,
  "Class " + iterReturnType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethodDef, iterMethodDef.getName()