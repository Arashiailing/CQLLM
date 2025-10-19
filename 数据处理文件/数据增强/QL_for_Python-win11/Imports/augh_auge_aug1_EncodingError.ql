/**
 * @name Encoding error
 * @description Detects encoding-related issues in code that may trigger runtime failures
 *              and impede static analysis capabilities.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

// Collect all encoding error instances with their diagnostic messages
import python

from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()