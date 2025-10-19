/**
 * @name Vulnerable hostname regular expression patterns
 * @description Identifies security vulnerabilities in regular expressions used for hostname or URL validation, specifically where dots are not correctly escaped, resulting in excessively permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the dedicated module for examining security vulnerabilities in regular expressions for hostnames
private import semmle.python.security.regexp.HostnameRegex as HostnamePatternChecker

// Main query predicate designed to uncover security issues in hostname regular expression patterns
query predicate hostnameRegexVulnerabilities = HostnamePatternChecker::incompleteHostnameRegExp/4;