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

from ClassValue iterOwnerClass, FunctionValue iterFunc, ClassValue iterReturnType
where
  // Step 1: Locate classes defining the __iter__ method
  iterFunc = iterOwnerClass.lookup("__iter__") and
  // Step 2: Extract the inferred return type from the __iter__ method
  iterReturnType = iterFunc.getAnInferredReturnType() and
  // Step 3: Verify the return type lacks iterator interface implementation
  not iterReturnType.isIterator()
select iterReturnType,
  "Class " + iterReturnType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterFunc, iterFunc.getName()