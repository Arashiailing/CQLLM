/**
 * @name Encoding error
 * @description Detects Python code with improper character encoding configurations 
 *              that could lead to runtime exceptions and hinder static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Find all encoding-related issues in the Python codebase
from EncodingError encodingIssue

// Retrieve the descriptive message for each encoding issue
// and display it together with the issue instance
select encodingIssue, encodingIssue.getMessage()