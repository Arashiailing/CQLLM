/**
 * @name Python extraction warnings
 * @description Detects Python files in the repository that have extraction warnings.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Provides the SARIF severity level for diagnostic warnings.
 * 
 * Reference: SARIF v2.1.0 specification at 
 * https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// Explanation of SARIF severity levels (according to the specification):
// - "error": A critical problem that causes analysis to abort or produce invalid results
// - "warning": A non-critical issue where analysis might be incomplete but results are still valid
// SyntaxErrors are treated as warnings because the results can still be valid despite incomplete analysis

from SyntaxError syntaxError
where exists(syntaxError.getFile().getRelativePath())
select 
  syntaxError, 
  "Extraction failed in " + syntaxError.getFile() + " with error " + syntaxError.getMessage(),
  getWarningSeverity()