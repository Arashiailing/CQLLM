/**
 * @name Python extraction warnings
 * @description Identifies extraction warnings for Python files in the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

// This query identifies syntax errors in Python source files and reports them as extraction warnings.
// As per SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338):
// - "error": Critical issue causing analysis to be aborted or results to be incorrect/incomplete
// - "warning": Non-critical issue where analysis may be incomplete but results are potentially valid
// SyntaxErrors are classified as warnings since analysis may be incomplete but generated results remain potentially valid.

from SyntaxError syntaxError, File problematicFile
where
  exists(problematicFile.getRelativePath()) and // Ensure the file has a valid relative path
  problematicFile = syntaxError.getFile() // Retrieve the file containing the syntax error
select 
  syntaxError, 
  "Extraction failed in " + problematicFile + " with error " + syntaxError.getMessage(), // Generate diagnostic message
  getWarningSeverity() // Assign the warning severity level

/**
 * Defines the SARIF severity level for warnings.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }