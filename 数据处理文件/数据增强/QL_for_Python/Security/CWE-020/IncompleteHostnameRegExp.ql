/**
 * @name Incomplete regular expression for hostnames
 * @description Matching a URL or hostname against a regular expression that contains an unescaped dot as part of the hostname might match more hostnames than expected.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// 导入用于检测主机名正则表达式的库
private import semmle.python.security.regexp.HostnameRegex as HostnameRegex

// 定义查询谓词，查找不完整的主机名正则表达式问题
query predicate problems = HostnameRegex::incompleteHostnameRegExp/4;
