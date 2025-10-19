/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security flaws in regular expressions that validate URLs or hostnames,
 *              specifically when dots are not correctly escaped, leading to overly broad
 *              hostname matching patterns that could bypass security controls.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for analyzing security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegExpAnalyzer

// Define the main query predicate that identifies vulnerable hostname regex patterns
// This predicate specifically detects cases where dots in hostname validation regexes
// are not properly escaped, which can lead to security vulnerabilities
query predicate vulnerableHostnameRegexPatterns = HostnameRegExpAnalyzer::incompleteHostnameRegExp/4;