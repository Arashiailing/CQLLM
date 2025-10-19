/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes returned by `__iter__` methods that fail to implement the iterator interface.
 *              Such classes trigger 'TypeError' when used in iteration contexts like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue classDefiningIter, FunctionValue iterMethod, ClassValue returnType
where
  // Identify classes defining the __iter__ method
  iterMethod = classDefiningIter.lookup("__iter__") and
  // Extract the inferred return type from the __iter__ method
  returnType = iterMethod.getAnInferredReturnType() and
  // Validate the return type lacks iterator interface implementation
  not returnType.isIterator()
select returnType,
  "Class " + returnType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()