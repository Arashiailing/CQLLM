/**
 * @name Encoding error
 * @description Detects encoding problems in Python code that could lead to 
 *              runtime errors and hinder static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify and report all encoding error instances with detailed messages
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()