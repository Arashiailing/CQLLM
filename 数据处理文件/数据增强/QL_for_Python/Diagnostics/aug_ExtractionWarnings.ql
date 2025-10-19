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
from SyntaxError syntaxErr, File sourceFile
where
  sourceFile = syntaxErr.getFile() and // Retrieve the file where the error occurred
  exists(sourceFile.getRelativePath()) // Ensure the file has a valid relative path
select 
  syntaxErr, 
  "Extraction failed in " + sourceFile + " with error " + syntaxErr.getMessage(), // Format diagnostic message
  getWarningSeverity() // Assign warning severity level