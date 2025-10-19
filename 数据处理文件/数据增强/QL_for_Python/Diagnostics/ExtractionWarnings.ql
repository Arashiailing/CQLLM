/**
 * @name Python extraction warnings
 * @description List all extraction warnings for Python files in the source code directory.
 * @kind diagnostic
 * @id py/diagnostics/extraction-warnings
 */

import python

/**
 * 获取警告的SARIF严重级别。
 *
 * 参考链接：https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338
 */
int getWarningSeverity() { result = 1 }

// SARIF规范（https://docs.oasis-open.org/sarif/sarif/v2.1.0/csprd01/sarif-v2.1.0-csprd01.html#_Toc10541338）定义了错误和警告：
//
// "error"：发现了一个严重问题。工具遇到的条件导致分析被中止或结果不正确或不完整。
//
// "warning"：发现了一个不被认为是严重的问题。工具遇到的条件不确定是否发生了问题，或者分析可能不完整但生成的结果可能是有效的。
//
// 因此，SyntaxErrors报告为警告级别，因为分析可能不完整但生成的结果是可能有效的。
from SyntaxError error, File file
where
  file = error.getFile() and // 获取发生错误的文件
  exists(file.getRelativePath()) // 确保文件有相对路径
select error, "Extraction failed in " + file + " with error " + error.getMessage(), // 选择错误信息并格式化输出
  getWarningSeverity() // 设置警告的严重级别
