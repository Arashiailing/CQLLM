/**
 * @name Vulnerable hostname regular expression patterns
 * @description Detects security vulnerabilities in regular expressions used for hostname or URL validation.
 *              This analysis focuses on patterns where dot characters (.) are not properly escaped,
 *              causing overly broad hostname matching that can be exploited to bypass security controls.
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
private import semmle.python.security.regexp.HostnameRegex as HostnameSecurityAnalyzer

// Define the main predicate that identifies and reports security vulnerabilities
// in hostname regular expression patterns where dots are not properly escaped
query predicate vulnerableHostnamePatterns = HostnameSecurityAnalyzer::incompleteHostnameRegExp/4;