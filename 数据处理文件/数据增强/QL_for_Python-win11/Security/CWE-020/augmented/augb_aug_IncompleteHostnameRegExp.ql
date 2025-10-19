/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security vulnerabilities in regular expressions used for URL or hostname matching.
 *              Specifically identifies patterns containing unescaped dots ('.') which can match any character,
 *              potentially allowing unauthorized hostname access beyond the intended scope.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// 导入用于分析主机名正则表达式安全问题的专用库
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexModule

// 定义主查询谓词，用于识别不完整主机名正则表达式的安全问题
// 该谓词作为HostnameRegex模块中核心分析逻辑的入口点
query predicate problems = HostnameRegexModule::incompleteHostnameRegExp/4;