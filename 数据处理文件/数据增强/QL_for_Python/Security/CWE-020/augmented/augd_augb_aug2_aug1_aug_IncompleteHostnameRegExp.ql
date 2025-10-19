/**
 * @name Vulnerable hostname regular expression patterns
 * @description Detects security flaws in regular expressions that validate URLs or hostnames, particularly when dots are not correctly escaped, leading to excessively permissive hostname matching.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for hostname regex security analysis
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexChecker

// Core query predicate that detects security issues in hostname regular expression patterns
query predicate hostnameRegexVulnerabilities = HostnameRegexChecker::incompleteHostnameRegExp/4;