/**
 * @name Character Encoding Issue
 * @description Identifies character encoding problems that lead to runtime exceptions and hinder code analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Locate encoding defects and their corresponding diagnostic information
from EncodingError encodingDefect
select encodingDefect, encodingDefect.getMessage()