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
 * 
 * Severity levels per SARIF specification:
 * - "error": Serious problem causing analysis abortion or incorrect/incomplete results
 * - "warning": Non-serious problem where analysis may be incomplete but results remain valid
 * 
 * SyntaxErrors are reported as warnings since analysis may be incomplete but results are potentially valid.
 */
int getWarningSeverity() { result = 1 }

from SyntaxError syntaxError, File errorFile
where 
  errorFile = syntaxError.getFile() and
  exists(errorFile.getRelativePath())
select 
  syntaxError, 
  "Extraction failed in " + errorFile + " with error " + syntaxError.getMessage(),
  getWarningSeverity()