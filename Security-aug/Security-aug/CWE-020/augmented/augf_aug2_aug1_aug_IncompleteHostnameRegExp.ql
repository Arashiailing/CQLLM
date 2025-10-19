/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security vulnerabilities in regular expressions used for URL or hostname validation where dots are not properly escaped, resulting in overly permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import specialized module for examining security weaknesses in hostname regular expression patterns
private import semmle.python.security.regexp.HostnameRegex as HostnamePatternChecker

// Define primary query predicate to identify security issues in hostname regular expression validation
query predicate flawedHostnamePatterns = HostnamePatternChecker::incompleteHostnameRegExp/4;