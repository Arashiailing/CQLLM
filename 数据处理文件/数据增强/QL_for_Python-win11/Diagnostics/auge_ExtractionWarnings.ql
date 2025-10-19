/**
 * @name Python extraction warnings
 * @description List all extraction warnings for Python files in the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * @returns SARIF 规范中定义的警告严重级别（1 = warning）。
 * @see https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// SARIF 规范定义了两种级别：
// - "error": 严重问题，导致分析被中止或结果不正确/不完整。
// - "warning": 非严重问题，分析可能不完整但结果可能有效。
// 语法错误（SyntaxError）被归类为警告级别，因为虽然分析可能不完整，
// 但生成的结果仍然可能是有效的。
from SyntaxError syntaxErr, File errFile
where
  errFile = syntaxErr.getFile() and
  exists(errFile.getRelativePath())
select
  syntaxErr,
  "Extraction failed in " + errFile + " with error " + syntaxErr.getMessage(),
  getWarningSeverity()