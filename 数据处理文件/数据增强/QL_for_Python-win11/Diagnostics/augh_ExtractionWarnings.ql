/**
 * @name Python extraction warnings
 * @description List all extraction warnings for Python files in the source code directory.
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

// SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338) defines:
// 
// "error": A serious problem was found. The tool encountered a condition that caused analysis to be aborted or results to be incorrect/incomplete.
// 
// "warning": A non-critical problem was found. The tool encountered a condition where a problem might exist, or analysis may be incomplete but results could still be valid.
// 
// Therefore, SyntaxErrors are reported as warnings since analysis might be incomplete but results could remain valid.
from SyntaxError syntaxIssue, File sourceFile
where 
  sourceFile = syntaxIssue.getFile() and // Identify file containing the error
  exists(sourceFile.getRelativePath())   // Validate file has relative path
select 
  syntaxIssue, 
  "Extraction failed in " + sourceFile + " with error " + syntaxIssue.getMessage(), // Format error message
  getWarningSeverity() // Assign warning severity level