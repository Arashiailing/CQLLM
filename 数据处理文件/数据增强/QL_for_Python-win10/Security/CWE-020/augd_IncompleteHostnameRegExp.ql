/**
 * @name Incomplete regular expression for hostnames
 * @description Detects regular expressions used to match URLs or hostnames that contain unescaped dots,
 * which can lead to matching more hostnames than intended. This can cause security vulnerabilities
 * when such regular expressions are used for validation or filtering purposes.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import library for detecting hostname regular expression issues
private import semmle.python.security.regexp.HostnameRegex as HostnameRegex

// Define the main query predicate to identify hostname-related regex problems
query predicate regexHostnameProblems = HostnameRegex::incompleteHostnameRegExp/4;