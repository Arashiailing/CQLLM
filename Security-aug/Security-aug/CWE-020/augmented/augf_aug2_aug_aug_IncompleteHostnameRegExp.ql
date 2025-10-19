/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security vulnerabilities in regular expressions that validate URLs or hostnames
 *              where dots are not correctly escaped, leading to overly permissive matching patterns.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for analyzing security issues related to hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexValidator

// Define the primary query predicate that identifies insecure hostname regex patterns
// This predicate specifically targets regex patterns used for hostname validation where dots are not properly escaped,
// which could result in unintended hostname matches and potential security bypasses
query predicate detectInsecureHostnameRegexPatterns = HostnameRegexValidator::incompleteHostnameRegExp/4;