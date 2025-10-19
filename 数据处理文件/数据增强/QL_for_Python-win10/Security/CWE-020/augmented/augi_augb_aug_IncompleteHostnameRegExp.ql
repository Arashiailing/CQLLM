/**
 * @name Incomplete regular expression for hostnames
 * @description Identifies security vulnerabilities in regular expressions used for URL or hostname validation.
 *              The query specifically detects patterns with unescaped dots ('.') that match any character,
 *              potentially enabling unauthorized hostname access outside the intended scope.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import specialized library for analyzing security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnamePatternChecker

// Main query predicate that identifies security issues in incomplete hostname regular expressions
// This predicate serves as the entry point to the core analysis logic in the HostnamePatternChecker module
query predicate problems = HostnamePatternChecker::incompleteHostnameRegExp/4;