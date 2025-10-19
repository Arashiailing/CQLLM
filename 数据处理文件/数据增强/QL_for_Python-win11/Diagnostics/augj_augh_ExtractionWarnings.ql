/**
 * @name Python extraction warnings
 * @description Identifies and reports all extraction warnings encountered in Python source files.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Specifies the SARIF severity level assigned to warnings.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// According to the SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338):
// 
// "error": Indicates a critical issue that caused analysis to be aborted or produced incorrect/incomplete results.
// 
// "warning": Indicates a non-critical issue where analysis might be incomplete but results could still be valid.
// 
// SyntaxErrors are classified as warnings because while analysis may be incomplete, the results remain potentially valid.
from SyntaxError syntaxError, File problemFile
where 
  exists(problemFile.getRelativePath()) and // Ensure the file has a valid relative path
  problemFile = syntaxError.getFile()       // Locate the file containing the syntax error
select 
  syntaxError, 
  "Extraction failed in " + problemFile + " with error " + syntaxError.getMessage(), // Construct descriptive error message
  getWarningSeverity() // Apply the appropriate warning severity level