/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes where the `__iter__` method returns a non-iterator object.
 *              Such classes would raise a 'TypeError' when used in a 'for' loop.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue classWithIterMethod, FunctionValue iterMethodInClass, ClassValue nonIteratorType
where
  // Identify classes defining an __iter__ method
  iterMethodInClass = classWithIterMethod.lookup("__iter__") and
  
  // Obtain the inferred return type of the __iter__ method
  nonIteratorType = iterMethodInClass.getAnInferredReturnType() and
  
  // Verify the return type doesn't implement iterator protocol
  not nonIteratorType.isIterator()
select nonIteratorType,
  "Class " + nonIteratorType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethodInClass, iterMethodInClass.getName()