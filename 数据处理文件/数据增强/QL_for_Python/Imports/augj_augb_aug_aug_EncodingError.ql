/**
 * @name Encoding error
 * @description Identifies Python encoding violations that may trigger runtime failures
 *              and impede static analysis effectiveness.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all encoding violations in the codebase
from EncodingError encodingViolation

// Extract diagnostic details for each violation
// and pair with the violation instance
select encodingViolation, encodingViolation.getMessage()