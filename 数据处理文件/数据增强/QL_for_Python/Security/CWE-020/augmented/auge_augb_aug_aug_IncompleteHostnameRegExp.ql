/**
 * @name Incomplete regular expression for hostnames
 * @description Identifies security vulnerabilities in regular expressions that validate URLs or hostnames. Specifically, this query detects patterns where dots (.) are not properly escaped, which can result in overly permissive hostname matching and potential security bypasses.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for analyzing hostname regex security issues
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexChecker

// Main query predicate to detect flawed hostname validation patterns
// This identifies regex patterns that may allow unauthorized hostname matches
// due to improper escaping of special characters, particularly dots
query predicate flawedHostnameValidation = HostnameRegexChecker::incompleteHostnameRegExp/4;