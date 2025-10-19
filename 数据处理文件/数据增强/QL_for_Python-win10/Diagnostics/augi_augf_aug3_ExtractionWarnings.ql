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

// SARIF severity levels:
// - "error": Critical issue causing analysis failure or invalid results
// - "warning": Non-critical issue where analysis may be partial but results remain valid
//
// SyntaxErrors are classified as warnings because:
// 1. Parsing issues may cause incomplete analysis
// 2. Results remain valid for unaffected code regions

from SyntaxError error, File affectedFile
where 
  // Ensure file has valid relative path in project context
  affectedFile = error.getFile() and
  exists(affectedFile.getRelativePath())
select 
  error, 
  "Extraction failed in " + affectedFile + " with error " + error.getMessage(),
  getWarningSeverity()