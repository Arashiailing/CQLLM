/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes (those not inheriting from 'object') do not support
 *              the memory optimization mechanism provided by `__slots__`. When `__slots__` is
 *              declared in such classes, it merely creates a regular class attribute without
 *              delivering the expected memory efficiency benefits.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python  // Import the Python library to access Python code elements

from ClassObject targetClass  // Select a class object for analysis
where 
  // Ensure the class inference was successful
  not targetClass.failedInference()
  // Check if the class is an old-style class (not inheriting from object)
  and not targetClass.isNewStyle()
  // Verify the class declares a __slots__ attribute
  and targetClass.declaresAttribute("__slots__")
select targetClass,  // Select the problematic class
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'." 
  // Warning message explaining the issue