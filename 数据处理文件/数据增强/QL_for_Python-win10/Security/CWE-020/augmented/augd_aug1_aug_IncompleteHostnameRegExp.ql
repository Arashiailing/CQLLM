/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security vulnerabilities in regular expressions used for URL or hostname validation
 *              where dots are not properly escaped, resulting in overly permissive hostname matching.
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
private import semmle.python.security.regexp.HostnameRegex as HostnameValidator

// Main query predicate that detects security issues in hostname regular expressions
// This predicate identifies patterns where hostname validation is insufficient
// due to unescaped dots in regular expressions
query predicate vulnerablePatterns = HostnameValidator::incompleteHostnameRegExp/4;