/**
 * @name Incomplete regular expression for hostnames
 * @description Detects security flaws in regular expressions used for URL or hostname validation
 *              where dots are not correctly escaped, leading to overly permissive hostname matching patterns.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the dedicated module for examining security issues in hostname regular expressions
private import semmle.python.security.regexp.HostnameRegex as HostnamePatternChecker

// Main query predicate to detect insecure hostname regex patterns
// This identifies cases where dots in hostname validation regexes are not properly escaped,
// which could lead to security vulnerabilities
query predicate insecureHostnameRegexValidation = 
    HostnamePatternChecker::incompleteHostnameRegExp/4;