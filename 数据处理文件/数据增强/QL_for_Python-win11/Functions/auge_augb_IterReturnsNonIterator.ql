/**
 * @name `__iter__` method returns non-iterator type
 * @description Identifies classes returned by `__iter__` methods that violate iterator protocol,
 *              which would trigger TypeError in iteration contexts (e.g., for-loops).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue sourceClass, FunctionValue iterMethod, ClassValue returnedClass
where
  // Locate classes defining __iter__ method
  iterMethod = sourceClass.lookup("__iter__") and
  // Extract the return type from __iter__ method
  returnedClass = iterMethod.getAnInferredReturnType() and
  // Validate return type lacks iterator implementation
  not returnedClass.isIterator()
select 
  returnedClass,
  "Class " + returnedClass.getName() + 
    " returned as iterator (by $@) but fails iterator protocol compliance.",
  iterMethod, iterMethod.getName()