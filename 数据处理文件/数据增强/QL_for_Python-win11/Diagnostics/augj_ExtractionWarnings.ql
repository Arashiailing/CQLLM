/**
 * @name Python extraction warnings
 * @description Identifies and reports extraction warnings for Python files in the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Determines the SARIF severity level for warnings.
 *
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int determineWarningSeverity() { result = 1 }

// According to the SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338),
// errors and warnings are defined as:
//
// "error": A serious problem was found. The tool encountered a condition that caused the analysis to be aborted
// or the results to be incorrect or incomplete.
//
// "warning": A problem was found that is not considered serious. The tool encountered a condition where it is
// uncertain whether a problem occurred, or the analysis may be incomplete but the generated results may be valid.
//
// Therefore, SyntaxErrors are reported at the warning level because the analysis may be incomplete but the generated
// results are potentially valid.
from SyntaxError syntaxErr, File sourceFile
where
  sourceFile = syntaxErr.getFile() and // Retrieve the file where the error occurred
  exists(sourceFile.getRelativePath()) // Ensure the file has a relative path
select syntaxErr, "Python extraction failed in " + sourceFile + " due to syntax error: " + syntaxErr.getMessage(), // Select and format the error message
  determineWarningSeverity() // Set the warning severity level