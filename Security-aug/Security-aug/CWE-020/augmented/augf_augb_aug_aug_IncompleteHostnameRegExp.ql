/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security vulnerabilities in regular expressions used for URL or hostname validation. This query specifically identifies patterns where dots (.) are not properly escaped, leading to overly permissive hostname matching and potential security bypasses.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the module for analyzing security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameValidator

// Define the primary query predicate to identify vulnerable hostname validation patterns
// This predicate detects regular expressions that may permit unauthorized hostname matches
// due to improper or incomplete escaping of special characters, especially dots
query predicate vulnerableHostnameValidation = HostnameValidator::incompleteHostnameRegExp/4;