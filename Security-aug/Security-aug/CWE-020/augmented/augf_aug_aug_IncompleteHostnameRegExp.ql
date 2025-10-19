/**
 * @name Incomplete regular expression for hostnames
 * @description Identifies security vulnerabilities in regular expressions used for URL or hostname validation
 *              where dots ('.') are not properly escaped, resulting in overly permissive pattern matching.
 *              Unescaped dots in regex match any character, potentially allowing malicious hostnames
 *              to bypass validation controls.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for analyzing security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexSecurity

// Define the main query predicate that identifies vulnerable hostname regex patterns
// This predicate references the core analysis logic from the imported module
query predicate insecureHostnameRegexPatterns = HostnameRegexSecurity::incompleteHostnameRegExp/4;