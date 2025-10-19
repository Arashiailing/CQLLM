/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security weaknesses in regular expressions used for URL or hostname validation. This query specifically identifies patterns where dots (.) are not correctly escaped, leading to excessively broad hostname matching and potential security bypasses.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for examining hostname regex security vulnerabilities
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexSecurityModule

// Primary query predicate for identifying defective hostname validation patterns
// This detects regex patterns that might permit unauthorized hostname matches
// resulting from incorrect escaping of special characters, especially dots
query predicate vulnerableHostnameRegex = HostnameRegexSecurityModule::incompleteHostnameRegExp/4;