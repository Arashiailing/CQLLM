/**
 * @name `__slots__` in old-style class
 * @description Using `__slots__` in old-style classes (not inheriting from `object`) 
 *              creates a regular class attribute instead of overriding the instance dictionary.
 *              This leads to unexpected behavior and memory inefficiency.
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
  problematicClass.declaresAttribute("__slots__") and 
  not problematicClass.isNewStyle() and 
  not problematicClass.failedInference()
select problematicClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."