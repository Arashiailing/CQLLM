/**
 * @name Python extraction warnings
 * @description Identifies and reports extraction warnings encountered during Python code analysis.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Computes the SARIF severity level for extraction warnings.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// SARIF specification defines severity levels as:
// - "error": Serious problem causing analysis abortion or incorrect/incomplete results
// - "warning": Non-serious problem where analysis may be incomplete but results remain valid
//
// SyntaxErrors are reported as warnings because:
// 1. Analysis may be incomplete due to parsing issues
// 2. Generated results are still potentially valid for non-affected code regions

from SyntaxError err, File targetFile
where 
  targetFile = err.getFile() and
  exists(targetFile.getRelativePath())
select 
  err, 
  "Extraction failed in " + targetFile + " with error " + err.getMessage(),
  getWarningSeverity()