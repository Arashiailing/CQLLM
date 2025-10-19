/**
 * @name `__slots__` in old-style class
 * @description Detects old-style classes (not inheriting from `object`) that use `__slots__`.
 *              In such classes, `__slots__` creates a regular class attribute instead of 
 *              overriding the instance dictionary mechanism. This negates memory optimization 
 *              and leads to unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject nonNewStyleClass
where 
  not nonNewStyleClass.failedInference() and
  not nonNewStyleClass.isNewStyle() and
  nonNewStyleClass.declaresAttribute("__slots__")
select nonNewStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."