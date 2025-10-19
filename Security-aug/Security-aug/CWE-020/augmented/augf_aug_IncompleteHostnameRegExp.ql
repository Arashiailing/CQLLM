/**
 * @name Incomplete regular expression for hostnames
 * @description Identifies security vulnerabilities where regular expressions for URL or hostname matching contain unescaped dots, potentially allowing broader hostname matches than intended.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// 引入用于主机名正则表达式安全性分析的专用库
private import semmle.python.security.regexp.HostnameRegex as HostnameRegExp

// 声明查询谓词，用于发现并标记存在安全风险的不完整主机名正则表达式
query predicate securityVulnerabilities = HostnameRegExp::incompleteHostnameRegExp/4;