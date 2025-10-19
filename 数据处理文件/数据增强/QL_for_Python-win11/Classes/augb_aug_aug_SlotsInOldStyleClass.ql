/**
 * @name `__slots__` in old-style class
 * @description Finds classes that don't inherit from 'object' (old-style) and define `__slots__`.
 *              In these cases, `__slots__` doesn't provide memory optimization as intended,
 *              but instead acts as a regular class attribute, causing unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject oldStyleClass
where 
  // Filter out new-style classes to identify old-style classes
  not oldStyleClass.isNewStyle() 
  and 
  // Verify that the class defines the __slots__ attribute
  oldStyleClass.declaresAttribute("__slots__") 
  and 
  // Confirm that the class analysis completed successfully
  not oldStyleClass.failedInference()
select oldStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."