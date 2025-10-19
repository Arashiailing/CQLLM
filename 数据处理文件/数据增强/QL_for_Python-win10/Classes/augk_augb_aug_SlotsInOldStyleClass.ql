/**
 * @name `__slots__` in old-style class
 * @description Old-style classes (not inheriting from object) improperly support `__slots__`.
 *              When defined, `__slots__` creates a standard class attribute instead of replacing
 *              the instance dictionary, causing unexpected behavior and increased memory usage.
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
  // Filter out classes where inference failed to prevent false positives
  not problematicClass.failedInference() and 
  // Identify old-style classes that don't inherit from object
  not problematicClass.isNewStyle() and 
  // Verify the problematic class declares __slots__
  problematicClass.declaresAttribute("__slots__")
select problematicClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."