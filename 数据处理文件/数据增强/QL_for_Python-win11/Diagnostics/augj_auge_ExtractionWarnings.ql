/**
 * @name Python extraction warnings
 * @description Identifies and reports all extraction warnings encountered during the analysis of Python files.
 *              This query helps identify files where extraction encountered issues, potentially affecting
 *              the completeness of the analysis.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Determines the severity level for warnings according to the SARIF specification.
 * @returns The integer value representing warning severity (1 = warning) as defined in SARIF.
 * @see https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// The SARIF specification defines two primary severity levels:
// - "error": Critical issues that cause analysis to abort or produce incorrect/incomplete results.
// - "warning": Non-critical issues where analysis might be incomplete but results could still be valid.
// Syntax errors are classified as warnings because while the analysis might be incomplete,
// the generated results can still be considered valid for the parts that were successfully analyzed.

from SyntaxError syntaxError, File errorFile
where
  // Ensure the syntax error is associated with a file that has a relative path
  errorFile = syntaxError.getFile() and
  exists(errorFile.getRelativePath())
select
  syntaxError,
  "Extraction failed in " + errorFile + " with error " + syntaxError.getMessage(),
  getWarningSeverity()