/**
 * @name Encoding error
 * @description Identifies encoding issues in Python code that may cause runtime failures
 *              and impede static analysis of the code.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all instances of encoding violations in the codebase
from EncodingError encodingViolation

// Extract the detailed message for each encoding violation
// and present it alongside the violation instance
select encodingViolation, encodingViolation.getMessage()