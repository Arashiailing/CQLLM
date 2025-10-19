/**
 * @name Encoding error detection
 * @description Identifies potential encoding issues in Python code that may cause runtime exceptions
 *              or interfere with static analysis. This query targets cases where improper encoding
 *              handling could lead to data corruption or execution failures.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Identify all encoding-related issues in the codebase
// Each issue represents a location where encoding errors might occur
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()