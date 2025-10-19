/**
 * @name Incomplete regular expression for hostnames
 * @description This query detects security vulnerabilities in regular expressions used for URL or hostname validation.
 *              Specifically, it identifies patterns where dots ('.') are not properly escaped, leading to overly
 *              permissive matching. Unescaped dots in regex match any character, which could allow malicious
 *              hostnames to bypass validation controls.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import specialized module for analyzing security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexSecurity

// Define the main query predicate to identify vulnerable hostname regex patterns
// This predicate leverages the core analysis logic from the imported module
query predicate vulnerableHostnameRegex = HostnameRegexSecurity::incompleteHostnameRegExp/4;