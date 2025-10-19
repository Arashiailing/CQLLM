/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security weaknesses in regular expressions used for URL or hostname validation where dots are not correctly escaped, resulting in excessively permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import specialized module for examining security aspects of hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexAnalyzer

// Define the main query predicate to detect security vulnerabilities in hostname regular expressions
// This predicate identifies patterns where hostname validation regex patterns are insufficient
query predicate insecureHostnamePatterns = HostnameRegexAnalyzer::incompleteHostnameRegExp/4;