/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security flaws in regular expressions designed for URL or hostname validation
 *              where dots are not correctly escaped, leading to excessively broad hostname matching patterns.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized module for examining security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnameValidator

// Define the primary query predicate that identifies insecure hostname regex patterns
// This predicate locates instances where dots within hostname validation regexes lack proper escaping
query predicate insecureHostnameRegex = HostnameValidator::incompleteHostnameRegExp/4;