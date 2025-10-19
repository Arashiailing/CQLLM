/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security weaknesses in regular expressions used for URL/hostname validation where dots are not properly escaped, resulting in overly permissive hostname matching.
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

/**
 * This predicate detects security vulnerabilities in hostname regular expressions.
 * It identifies patterns where dots are not properly escaped, which could lead
 * to overly permissive hostname matching and potential security bypasses.
 */
query predicate insecureHostnameRegexPatterns = HostnameRegexChecker::incompleteHostnameRegExp/4;