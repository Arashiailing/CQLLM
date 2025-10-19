/**
 * @name Old-style class with `__slots__` attribute
 * @description Identifies classes that do not inherit from 'object' (old-style classes) 
 *              but define the `__slots__` attribute. In old-style classes, `__slots__` 
 *              does not provide memory optimization benefits and instead functions as a 
 *              regular class attribute, which can lead to unexpected behavior and reduced performance.
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
  // Ensure class analysis was successful
  not oldStyleClass.failedInference()
  and
  // Identify non-new-style classes (old-style)
  not oldStyleClass.isNewStyle() 
  and 
  // Check if class declares __slots__ attribute
  oldStyleClass.declaresAttribute("__slots__") 
select oldStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."