/**
 * @name Python extraction warnings
 * @description Identifies and reports extraction warnings for Python files in the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

// SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338)
// defines two severity levels:
//
// "error": Indicates a severe issue that causes analysis to abort or produces incorrect/incomplete results.
//
// "warning": Indicates a non-severe issue where analysis might be incomplete but results could still be valid.
//
// Based on this specification, syntax errors are classified as warning level because while
// analysis might be incomplete, the generated results can still be valuable.

/**
 * Determines the SARIF severity level for warnings.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// Define variables for syntax errors and associated Python files
from SyntaxError pySyntaxError, File pyFile
where
  // Associate syntax error with its source file
  pyFile = pySyntaxError.getFile() and
  // Ensure the file has an accessible relative path
  exists(pyFile.getRelativePath())
select 
  pySyntaxError, 
  // Format a descriptive error message
  "Extraction failed in " + pyFile + " with error " + pySyntaxError.getMessage(),
  // Apply the warning severity level
  getWarningSeverity()