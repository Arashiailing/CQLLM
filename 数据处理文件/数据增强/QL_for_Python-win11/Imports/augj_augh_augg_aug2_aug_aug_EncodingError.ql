/**
 * @name Character Encoding Misconfiguration
 * @description Identifies Python source code containing improper character encoding settings
 *              that may result in runtime failures and impede static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// This query scans the Python codebase to identify all occurrences of encoding misconfigurations
// Such issues may trigger runtime exceptions and adversely affect static analysis processes
from EncodingError encodingDefect

// For each identified encoding defect, obtain its detailed diagnostic message
// and present both the defect instance and message in the query output
select encodingDefect, encodingDefect.getMessage()