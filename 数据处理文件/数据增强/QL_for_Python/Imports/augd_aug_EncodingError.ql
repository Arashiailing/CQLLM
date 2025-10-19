/**
 * @name Encoding error
 * @description Identifies Python encoding issues that may cause runtime failures
 *              and impede static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all encoding violation instances in Python code
from EncodingError encodingViolation

// Report encoding violations with diagnostic details
select encodingViolation, encodingViolation.getMessage()