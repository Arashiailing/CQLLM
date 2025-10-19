/**
 * @name Encoding error
 * @description Identifies Python source code encoding violations that can lead to
 *              runtime failures and impede effective static analysis. These issues
 *              often arise when non-standard character encodings are used or when
 *              encoding declarations are missing or incorrect.
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

// Generate results containing the violation instance and its diagnostic message
select encodingViolation, encodingViolation.getMessage()