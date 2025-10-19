/**
 * @name Python extraction warnings
 * @description Identifies extraction warnings for Python files in the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Determines the SARIF severity level for warnings.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338) defines error levels:
//
// "error": A critical issue was found. The tool encountered a condition that caused analysis to be aborted or results to be incorrect/incomplete.
//
// "warning": A non-critical issue was found. The tool encountered a condition where it's uncertain if a problem occurred, or analysis may be incomplete but generated results are potentially valid.
//
// SyntaxErrors are reported as warnings since analysis may be incomplete but generated results remain potentially valid.

// Identify Python syntax errors that occurred in source files
from SyntaxError syntaxError, File errorFile
where
  // Establish the relationship between the syntax error and its containing file
  errorFile = syntaxError.getFile() and
  // Verify the file is within the source code directory by checking for a valid relative path
  exists(errorFile.getRelativePath())
select 
  syntaxError, 
  // Construct a descriptive diagnostic message containing file location and error details
  "Extraction failed in " + errorFile + " with error " + syntaxError.getMessage(),
  // Assign the appropriate warning severity level according to SARIF specification
  getWarningSeverity()