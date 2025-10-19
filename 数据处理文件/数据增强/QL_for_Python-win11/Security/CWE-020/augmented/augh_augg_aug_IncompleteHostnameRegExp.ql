/**
 * @name Incomplete regular expression for hostnames
 * @description Identifies security vulnerabilities in regular expressions used for URL or hostname validation.
 *              Specifically targets patterns with unescaped dot characters that can match more hostnames
 *              than intended, potentially enabling attackers to bypass security controls.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// Import the specialized analysis library for hostname regular expression security issues
private import semmle.python.security.regexp.HostnameRegex as HostnameRegexLib

// Main detection predicate for identifying vulnerable hostname regex patterns
// This predicate utilizes the imported library's capabilities to detect incomplete hostname regex patterns
// that could result in improper hostname validation and potential security bypasses
query predicate vulnerableHostnamePattern = HostnameRegexLib::incompleteHostnameRegExp/4;