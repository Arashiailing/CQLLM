/**
 * @name Python extraction warnings
 * @description Identifies extraction warnings for Python files in the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

// This query detects syntax errors in Python source files and reports them as extraction warnings.
// According to SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338):
// - "error": Critical issue causing analysis to be aborted or results to be incorrect/incomplete
// - "warning": Non-critical issue where analysis may be incomplete but results are potentially valid
// SyntaxErrors are reported as warnings since analysis may be incomplete but generated results remain potentially valid.

from SyntaxError pySyntaxError, File erroneousFile
where
  erroneousFile = pySyntaxError.getFile() and // Get the file containing the syntax error
  exists(erroneousFile.getRelativePath()) // Verify the file has a valid relative path
select 
  pySyntaxError, 
  "Extraction failed in " + erroneousFile + " with error " + pySyntaxError.getMessage(), // Construct diagnostic message
  getWarningSeverity() // Set the warning severity level

/**
 * Determines the SARIF severity level for warnings.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }