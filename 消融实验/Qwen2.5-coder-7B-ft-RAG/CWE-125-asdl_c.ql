/**
 * @name CWE-125: Out-of-bounds Read
 * @description The product reads data past the end, or before the beginning, of the intended buffer.
 * @kind problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/asdl_c
 */

import python
import semmle.python.Concepts
import ASDL_C

ASDL_C::out_of_bounds_read_vulnerability(node)