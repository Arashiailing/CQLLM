/**
 * @name Vulnerable hostname regular expression patterns
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

// Import specialized library for analyzing security of hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexChecker

// Define query predicate to identify security vulnerabilities in hostname regular expressions
query predicate vulnerablePatterns = HostnameRegexChecker::incompleteHostnameRegExp/4;