/**
 * @name Python extraction warnings
 * @description Detects and reports warnings that occur during the extraction phase of Python code analysis.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Determines the SARIF severity level for warnings.
 * 
 * This function returns the integer value corresponding to the 'warning' level
 * as defined in the SARIF specification.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int determineWarningSeverity() { result = 1 }

// SARIF specification defines severity levels as follows:
// - "error": A serious problem that causes analysis to be aborted or results to be incorrect/incomplete.
// - "warning": A less serious problem where analysis may be incomplete but results are potentially valid.
//
// SyntaxErrors are classified as warnings because while they may cause incomplete analysis,
// the results generated for the successfully parsed parts remain valid.

from SyntaxError syntaxError, File affectedFile
where 
  affectedFile = syntaxError.getFile() and
  exists(affectedFile.getRelativePath())
select 
  syntaxError, 
  "Extraction failed in " + affectedFile + " with error " + syntaxError.getMessage(),
  determineWarningSeverity()