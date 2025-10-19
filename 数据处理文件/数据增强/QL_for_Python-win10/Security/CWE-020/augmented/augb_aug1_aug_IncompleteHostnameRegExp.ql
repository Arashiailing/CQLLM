/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security vulnerabilities in regular expressions used for URL or hostname validation 
 *              where dots are not properly escaped, resulting in overly permissive hostname matching that 
 *              could lead to security bypasses.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import specialized library for analyzing security implications of hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexSecurityChecker

// Main query predicate that identifies vulnerable hostname regex patterns
// This predicate leverages the HostnameRegexSecurityChecker module to detect
// regular expressions that do not properly escape dots, leading to potential
// security vulnerabilities in hostname validation.
query predicate vulnerablePatterns = HostnameRegexSecurityChecker::incompleteHostnameRegExp/4;