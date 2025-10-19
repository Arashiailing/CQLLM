/**
 * @name Encoding error
 * @description Identifies encoding issues in Python code that may cause runtime failures
 *              and impede static analysis. This query detects problematic encoding
 *              declarations that violate Python's syntax requirements.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Retrieve all encoding violations in Python source files
from EncodingError encodingViolation

// Report each violation with contextual diagnostic information
select encodingViolation, encodingViolation.getMessage()