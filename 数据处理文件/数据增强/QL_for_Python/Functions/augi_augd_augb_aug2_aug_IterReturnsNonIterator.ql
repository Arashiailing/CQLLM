/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes returned by `__iter__` methods that fail to implement the iterator protocol.
 *              Such classes trigger 'TypeError' when used in iteration constructs like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerCls, FunctionValue iterMethodDef, ClassValue returnedCls
where
  // Find the __iter__ method definition within a container class
  iterMethodDef = containerCls.lookup("__iter__")
  and
  // Extract the inferred return type of the __iter__ method
  returnedCls = iterMethodDef.getAnInferredReturnType()
  and
  // Confirm the return type does not implement the iterator protocol
  not returnedCls.isIterator()
select returnedCls,
  "Class " + returnedCls.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethodDef, iterMethodDef.getName()