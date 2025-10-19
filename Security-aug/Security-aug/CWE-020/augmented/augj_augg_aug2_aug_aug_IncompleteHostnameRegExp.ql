/**
 * @name Unescaped dot in hostname validation regex
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

// Import the specialized analysis module for detecting security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexSecurityAnalyzer

/**
 * Core detection predicate for identifying vulnerable hostname regex patterns.
 * This predicate finds instances where dots in hostname validation regexes are not correctly escaped,
 * potentially creating security weaknesses in input validation mechanisms.
 */
query predicate insecureHostnameRegexValidation = HostnameRegexSecurityAnalyzer::incompleteHostnameRegExp/4;