/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes returned by `__iter__` methods that don't implement the iterator interface.
 *              Such classes cause 'TypeError' when used in iteration contexts (e.g., 'for' loops).
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
  // Verify the return type lacks iterator interface implementation
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()