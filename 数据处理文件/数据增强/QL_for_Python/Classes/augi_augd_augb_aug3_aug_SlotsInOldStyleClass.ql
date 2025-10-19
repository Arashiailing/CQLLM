/**
 * @name `__slots__` in old-style class
 * @description In old-style classes (not inheriting from `object`), `__slots__` is incorrectly 
 *              implemented as a regular class attribute instead of overriding instance dictionary 
 *              behavior. This defeats memory optimization and leads to unexpected behavior.
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
  // Filter classes that don't inherit from object
  not oldStyleClass.isNewStyle() 
  // Check for explicit __slots__ attribute declaration
  and oldStyleClass.declaresAttribute("__slots__") 
  // Exclude classes with analysis failures to ensure reliability
  and not oldStyleClass.failedInference()
select oldStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."