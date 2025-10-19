/**
 * @name Python extraction warnings
 * @description Detects extraction warnings in Python source files within the codebase.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * Specifies the SARIF severity level for extraction warnings.
 * 
 * According to SARIF specification (v2.1.0), severity levels are defined as:
 * - "error": Critical issues that abort analysis or produce incorrect/incomplete results.
 * - "warning": Non-critical issues where analysis might be incomplete but results are potentially valid.
 * 
 * Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 * 
 * SyntaxErrors are classified as warnings since while analysis may be incomplete,
 * the generated results remain potentially valid.
 */
int getWarningSeverity() { result = 1 }

from SyntaxError parseError, File pythonFile
where
  pythonFile = parseError.getFile() and
  exists(pythonFile.getRelativePath())
select 
  parseError, 
  "Extraction failed in " + pythonFile + " with error " + parseError.getMessage(),
  getWarningSeverity()