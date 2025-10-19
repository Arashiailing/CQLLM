/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes where `__iter__` returns non-iterator objects,
 *              causing 'TypeError' when used in iteration contexts.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue cls, FunctionValue iterFunc, ClassValue retType
where
  // Locate the __iter__ method within the target class
  iterFunc = cls.lookup("__iter__")
  and
  // Obtain the inferred return type of the __iter__ method
  retType = iterFunc.getAnInferredReturnType()
  and
  // Verify the return type fails to implement iterator interface
  not retType.isIterator()
select retType,
  "Class " + retType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterFunc, iterFunc.getName()