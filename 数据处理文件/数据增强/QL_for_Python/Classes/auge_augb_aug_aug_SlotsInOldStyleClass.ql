/**
 * @name `__slots__` in old-style class
 * @description Identifies legacy-style classes that do not inherit from 'object' (old-style) 
 *              yet define the `__slots__` attribute. In such scenarios, `__slots__` fails 
 *              to deliver the intended memory optimization and instead behaves as a 
 *              conventional class attribute, potentially leading to unexpected behavior.
 *              This issue is particularly relevant when migrating code from Python 2.x to 3.x,
 *              as the behavior of `__slots__` differs significantly between old-style and new-style classes.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject legacyStyleClass
where 
  // First, verify the class analysis completed successfully without inference failures
  not legacyStyleClass.failedInference()
  and
  // Then, identify classes that do not inherit from 'object' (old-style classes)
  not legacyStyleClass.isNewStyle() 
  and 
  // Finally, check for the presence of the __slots__ attribute definition
  legacyStyleClass.declaresAttribute("__slots__") 
select legacyStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."