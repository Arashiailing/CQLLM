/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security issues in regular expressions used for URL or hostname validation where dots are not properly escaped, leading to overly permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// 导入专门用于检查主机名正则表达式安全性的模块
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexSecurity

// 定义查询谓词，用于识别存在安全风险的主机名正则表达式模式
query predicate hostnameRegexVulnerabilities = HostnameRegexSecurity::incompleteHostnameRegExp/4;