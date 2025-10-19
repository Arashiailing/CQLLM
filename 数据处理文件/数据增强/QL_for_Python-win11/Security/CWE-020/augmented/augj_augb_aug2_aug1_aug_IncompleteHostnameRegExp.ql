/**
 * @name Vulnerable hostname regular expression patterns
 * @description Detects security flaws in regular expressions used for URL or hostname validation, focusing on cases where dots are not properly escaped, leading to overly permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import specialized module for analyzing security flaws in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexChecker

// Main query predicate to detect security flaws in hostname regular expression patterns
query predicate detectHostnameRegexFlaws = HostnameRegexChecker::incompleteHostnameRegExp/4;