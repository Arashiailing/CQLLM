/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes (those not inheriting from `object`) 
 *              do not correctly implement the `__slots__` special attribute. 
 *              When `__slots__` is used in such classes, it merely creates a regular 
 *              class attribute rather than overriding the instance dictionary mechanism. 
 *              This leads to unexpected behavior and defeats the memory-saving purpose 
 *              of `__slots__`.
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
  not oldStyleClass.isNewStyle() and 
  oldStyleClass.declaresAttribute("__slots__") and 
  not oldStyleClass.failedInference()
select oldStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."