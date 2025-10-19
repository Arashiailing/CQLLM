/**
 * @name 主机名正则表达式中的未转义点
 * @description 检测用于匹配主机名或URL的正则表达式中包含未转义的点，这可能导致意外的匹配。
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// 导入用于检测主机名正则表达式问题的库
private import semmle.python.security.regexp.HostnameRegex as HostnameRegex

// 定义主查询谓词，用于识别不完整的主机名正则表达式模式
query predicate incompleteHostnameRegexIssues = HostnameRegex::incompleteHostnameRegExp/4;