/**
 * @name Encoding error
 * @description Detects Python encoding issues that may cause runtime failures
 *              and hinder static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all encoding-related violations in the codebase
// For each violation, capture its detailed diagnostic message
// and present the violation alongside its corresponding message
from EncodingError encodingViolation

select encodingViolation,
       encodingViolation.getMessage()