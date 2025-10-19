/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes where the `__iter__` method returns an object 
 *              that doesn't satisfy the iterator protocol. Such classes would 
 *              raise a 'TypeError' when used in iteration contexts like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iterFunction, ClassValue returnedType
where
  // Identify classes implementing the __iter__ method
  iterFunction = containerClass.lookup("__iter__") and
  
  // Retrieve the inferred return type of the __iter__ method
  returnedType = iterFunction.getAnInferredReturnType() and
  
  // Verify the return type lacks iterator protocol implementation
  not returnedType.isIterator()
select returnedType,
  "Class " + returnedType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterFunction, iterFunction.getName()