/**
 * @name Encoding error
 * @description Detects Python encoding problems that could lead to runtime exceptions
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

// Find all occurrences of encoding errors in the codebase
from EncodingError problematicEncoding

// Report each identified encoding error along with its diagnostic message
select problematicEncoding, problematicEncoding.getMessage()