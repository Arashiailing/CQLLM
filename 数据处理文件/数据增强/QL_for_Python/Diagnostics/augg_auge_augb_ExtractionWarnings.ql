/**
 * @name Python extraction warnings
 * @description Detects and reports extraction warnings encountered during Python code analysis
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

// SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338)
// defines two severity levels:
// - "error": Critical issues causing analysis abortion or incorrect results
// - "warning": Non-critical issues where analysis may be incomplete but results remain valid
//
// Syntax errors are classified as warnings since partial analysis can still yield valuable results

/**
 * Returns SARIF severity level for extraction warnings
 * Reference: SARIF v2.1.0 specification (Section 3.27.4)
 */
int getWarningSeverity() { result = 1 }

// Identify syntax errors and their source files
from SyntaxError err, File sourceFile
where
  // Link syntax error to its originating file
  sourceFile = err.getFile() and
  // Verify file has accessible relative path
  exists(sourceFile.getRelativePath())
select 
  err, 
  // Generate descriptive error message
  "Extraction failed in " + sourceFile + " due to: " + err.getMessage(),
  // Assign warning severity level
  getWarningSeverity()