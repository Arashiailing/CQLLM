/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security weaknesses in regular expressions used for URL or hostname validation, specifically when dots are not properly escaped, resulting in overly permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import specialized module for analyzing security vulnerabilities in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameValidator

// Main query predicate to identify security vulnerabilities in hostname regular expression patterns
query predicate hostnamePatternVulnerabilities = HostnameValidator::incompleteHostnameRegExp/4;