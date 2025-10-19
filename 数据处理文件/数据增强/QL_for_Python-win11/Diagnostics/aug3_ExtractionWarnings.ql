/**
 * @name Python extraction warnings
 * @description Identifies and reports extraction warnings encountered during Python code analysis.
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

// According to SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338):
// 
// "error": A serious problem was found. The condition encountered by the tool caused analysis to be aborted, 
// or the results to be incorrect or incomplete.
//
// "warning": A problem that is not considered serious was found. The condition encountered by the tool is 
// uncertain whether a problem occurred, or the analysis may be incomplete but the results generated may be valid.
//
// Therefore, SyntaxErrors are reported as warning level because analysis may be incomplete but the generated 
// results are potentially valid.

from SyntaxError syntaxErr, File sourceFile
where 
  sourceFile = syntaxErr.getFile() and
  exists(sourceFile.getRelativePath())
select 
  syntaxErr, 
  "Extraction failed in " + sourceFile + " with error " + syntaxErr.getMessage(),
  getWarningSeverity()