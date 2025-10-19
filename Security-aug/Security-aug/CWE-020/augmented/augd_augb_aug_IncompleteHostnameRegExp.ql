/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security vulnerabilities in regular expressions used for URL or hostname matching.
 *              Specifically identifies patterns containing unescaped dots ('.') which can match any character,
 *              potentially allowing unauthorized hostname access beyond the intended scope.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized library for analyzing security vulnerabilities in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameSecurityAnalyzer

// Define the main query predicate to identify security issues in hostname regular expressions
// This predicate serves as the entry point for the core analysis logic within the HostnameSecurityAnalyzer module
query predicate problems = HostnameSecurityAnalyzer::incompleteHostnameRegExp/4;