/**
 * @name Encoding error
 * @description Detects Python encoding issues that may trigger runtime exceptions
 *              and obstruct static analysis. These problems typically emerge during
 *              text processing operations lacking proper character encoding management.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// This query scans the entire codebase for encoding-related defects
// and collects their diagnostic messages for reporting purposes
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()