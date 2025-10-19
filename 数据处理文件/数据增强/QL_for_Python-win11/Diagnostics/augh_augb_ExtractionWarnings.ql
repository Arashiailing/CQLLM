/**
 * @name Python extraction warnings
 * @description Detects and reports extraction warnings for Python files within the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * SARIF规范（https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338）区分了两种严重级别：
 *
 * "error"：表示发现严重问题，导致分析中止或结果不正确/不完整。
 *
 * "warning"：表示发现非严重问题，分析可能不完整但结果可能仍然有效。
 *
 * 基于此规范，语法错误(SyntaxErrors)被归类为警告级别，因为尽管分析可能不完整，但生成的结果仍然可能有效。
 */

/**
 * 确定警告的SARIF严重级别。
 * 
 * 参考文档：https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

from SyntaxError pySyntaxError, File sourceFileLocation
where 
  sourceFileLocation = pySyntaxError.getFile() and // 关联语法错误与其源文件
  exists(sourceFileLocation.getRelativePath())   // 验证文件具有可访问的相对路径
select 
  pySyntaxError, 
  "Extraction failed in " + sourceFileLocation + " with error " + pySyntaxError.getMessage(), // 格式化错误消息
  getWarningSeverity() // 应用警告严重级别