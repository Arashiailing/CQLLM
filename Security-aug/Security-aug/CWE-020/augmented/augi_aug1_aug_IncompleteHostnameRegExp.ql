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

// Import the specialized library module that provides functionality for analyzing
// the security aspects of regular expressions used for hostname validation
private import semmle.python.security.regexp.HostnameRegex as HostnameSecurityAnalyzer

// Define the main query predicate that identifies security vulnerabilities
// in regular expressions used for hostname validation, specifically targeting
// patterns where dots are not properly escaped
query predicate vulnerableHostnamePatterns = HostnameSecurityAnalyzer::incompleteHostnameRegExp/4;