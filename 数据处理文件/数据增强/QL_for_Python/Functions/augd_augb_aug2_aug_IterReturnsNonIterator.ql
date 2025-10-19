/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes returned by `__iter__` methods that don't implement the iterator protocol.
 *              These classes will cause 'TypeError' when used in iteration contexts like 'for' loops.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iterMethod, ClassValue returnedClass
where
  // Locate the __iter__ method within a container class
  iterMethod = containerClass.lookup("__iter__")
  and
  // Obtain the inferred return type of the __iter__ method
  returnedClass = iterMethod.getAnInferredReturnType()
  and
  // Verify the return type lacks iterator protocol implementation
  not returnedClass.isIterator()
select returnedClass,
  "Class " + returnedClass.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()