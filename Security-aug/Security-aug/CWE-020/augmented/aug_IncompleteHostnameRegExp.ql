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

// 导入用于分析主机名正则表达式安全性的专用库
private import semmle.python.security.regexp.HostnameRegex as HostnameRegExp

// 定义查询谓词，用于检测不完整的主机名正则表达式安全问题
query predicate problems = HostnameRegExp::incompleteHostnameRegExp/4;