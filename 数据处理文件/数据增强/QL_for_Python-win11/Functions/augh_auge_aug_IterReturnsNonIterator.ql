/**
 * @name `__iter__` method returns a non-iterator
 * @description Identifies classes returned by `__iter__` methods that lack iterator interface implementation.
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

from ClassValue iterDefiningClass, FunctionValue iterMethod, ClassValue returnedType
where
  // Locate classes defining the __iter__ method
  iterMethod = iterDefiningClass.lookup("__iter__")
  and
  // Obtain the inferred return type of the __iter__ method
  returnedType = iterMethod.getAnInferredReturnType()
  and
  // Validate the return type fails to implement iterator interface
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()