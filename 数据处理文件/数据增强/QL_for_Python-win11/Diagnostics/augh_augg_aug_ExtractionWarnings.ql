/**
 * @name Python extraction warnings
 * @description Detects extraction warnings in Python source files during code analysis.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

// SARIF severity level assignment for warnings
// Reference: https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
int getWarningSeverity() { result = 1 }

// SARIF specification defines error levels:
// "error": Critical issue causing analysis abortion or incorrect/incomplete results
// "warning": Non-critical issue where analysis may be incomplete but results are potentially valid
// SyntaxErrors are treated as warnings since results remain valid despite potential analysis incompleteness
from SyntaxError syntaxErr, File problematicFile
where
  // Establish relationship between syntax error and its containing file
  problematicFile = syntaxErr.getFile()
  and
  // Verify the file has a valid relative path within the project structure
  exists(problematicFile.getRelativePath())
select 
  syntaxErr, 
  "Extraction failed in " + problematicFile + " with error " + syntaxErr.getMessage(),
  getWarningSeverity()