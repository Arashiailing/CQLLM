/**
 * @name Python extraction warnings
 * @description Identifies Python files with extraction warnings in the repository.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Returns SARIF severity level for diagnostic warnings.
 * 
 * See SARIF v2.1.0 spec: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// SARIF severity levels (per specification):
// - "error": Critical issue causing analysis abortion or invalid results
// - "warning": Non-critical issue where analysis may be incomplete but results remain valid
// SyntaxErrors are classified as warnings since results are potentially valid despite incomplete analysis

from SyntaxError err, File file
where
  file = err.getFile() and
  exists(file.getRelativePath())
select 
  err, 
  "Extraction failed in " + file + " with error " + err.getMessage(),
  getWarningSeverity()