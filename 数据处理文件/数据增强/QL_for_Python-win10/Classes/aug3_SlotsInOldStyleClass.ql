/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes do not support the `__slots__` mechanism.
 *              When `__slots__` is declared in an old-style class, it simply creates
 *              a regular class attribute rather than optimizing memory usage.
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
  // Check if the class is an old-style class (not inheriting from object)
  not targetClass.isNewStyle() 
  // Verify that the class declares a __slots__ attribute
  and targetClass.declaresAttribute("__slots__") 
  // Ensure the class inference was successful
  and not targetClass.failedInference() 
select targetClass,  // Select the problematic class
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'." 
  // Warning message explaining the issue