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

// Import the module specialized for analyzing security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameValidator

// Define the main query predicate to detect insecure hostname validation patterns
// This predicate identifies regular expressions that may allow unauthorized hostname matches
// due to incomplete or improper escaping of special characters, particularly dots
query predicate insecureHostnamePatterns = HostnameValidator::incompleteHostnameRegExp/4;