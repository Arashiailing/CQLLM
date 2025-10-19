/**
 * @name Encoding error
 * @description Identifies Python encoding violations that may lead to runtime failures
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

// Retrieve each violation's diagnostic message and present it alongside the violation instance
select encodingViolation, encodingViolation.getMessage()