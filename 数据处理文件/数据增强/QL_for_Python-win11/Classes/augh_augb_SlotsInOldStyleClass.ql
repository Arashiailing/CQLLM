/**
 * @name `__slots__` in old-style class
 * @description In Python, declaring `__slots__` in old-style classes doesn't provide memory optimization
 *              because it merely creates a regular class attribute instead of overriding the instance dictionary.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject problematicClass
where 
  // Check if the class is an old-style class (not inheriting from object)
  not problematicClass.isNewStyle() and 
  // Verify that the class declares the __slots__ attribute
  problematicClass.declaresAttribute("__slots__") and 
  // Ensure that the class inference was successful
  not problematicClass.failedInference()
select problematicClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."