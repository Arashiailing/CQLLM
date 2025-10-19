/**
 * @name Python extraction warnings
 * @description Detects and reports extraction warnings for Python files within the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * SARIF specification (https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338) 
 * defines two severity levels:
 *
 * - "error": Indicates a serious problem that caused the analysis to stop or produce incorrect/incomplete results.
 * - "warning": Indicates a non-serious problem where analysis may be incomplete but results may still be valid.
 *
 * Following this specification, syntax errors are classified as warnings because although 
 * the analysis might be incomplete, the generated results can still be valid.
 */

from SyntaxError syntaxErr, File srcFile
where 
  srcFile = syntaxErr.getFile() and
  exists(srcFile.getRelativePath())
select 
  syntaxErr, 
  "Extraction failed in " + srcFile + " with error " + syntaxErr.getMessage(),
  1 // Warning severity level as per SARIF specification