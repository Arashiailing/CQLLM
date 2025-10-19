/**
 * @name Vulnerable hostname regular expression patterns
 * @description Detects security vulnerabilities in regular expressions used for URL or hostname validation where dots are not properly escaped, leading to overly permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for analyzing security issues in hostname regular expression patterns
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexSecurityChecker

// Define the main query predicate to detect security vulnerabilities in hostname regular expression validation
query predicate vulnerableHostnameRegexPatterns = HostnameRegexSecurityChecker::incompleteHostnameRegExp/4;