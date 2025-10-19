/**
 * @name Encoding error
 * @description Identifies Python encoding issues that can lead to runtime exceptions
 *              and hinder static analysis. These issues commonly occur during text 
 *              processing operations when proper character encoding handling is absent.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// This query systematically examines the codebase for encoding-related problems
// and gathers their diagnostic information for reporting
from EncodingError encodingDefect
select encodingDefect, encodingDefect.getMessage()