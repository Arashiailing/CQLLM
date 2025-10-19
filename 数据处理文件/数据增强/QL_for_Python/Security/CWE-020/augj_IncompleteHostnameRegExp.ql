/**
 * @name Incomplete regular expression for hostnames
 * @description Detects regular expressions used for hostname validation that contain unescaped dots, which could lead to overly permissive matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// 导入主机名正则表达式验证模块
private import semmle.python.security.regexp.HostnameRegex as HostnamePatternChecker

// 查询定义：识别不完整的主机名正则表达式模式
// 这些模式可能包含未转义的点号，导致意外的主机名匹配
query predicate problems = HostnamePatternChecker::incompleteHostnameRegExp/4;