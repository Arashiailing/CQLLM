/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security weaknesses in regular expressions utilized for URL or hostname validation.
 *              This query specifically targets patterns where dots (.) are not properly escaped,
 *              resulting in overly permissive hostname matching that could lead to security bypasses.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized analysis module for security assessment of hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameSecurityAnalyzer

// Define the main predicate to detect and report security vulnerabilities in hostname regular expression patterns
query predicate hostnameValidationFlaws = HostnameSecurityAnalyzer::incompleteHostnameRegExp/4;