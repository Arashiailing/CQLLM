/**
 * @name Inefficient regular expression
 * @description A regular expression that requires exponential time to match certain inputs
 *              can be a performance bottleneck, and may be vulnerable to denial-of-service
 *              attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/redos
 * @tags security
 *       external/cwe/cwe-1333
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// Import regex tree view module with alias for structural analysis
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
// Import exponential backtracking detection module configured with TreeView
import codeql.regex.nfa.ExponentialBackTracking::Make<TreeView>

// Identify vulnerable regex terms and their attack characteristics
from TreeView::RegExpTerm term, string repeatedString, State state, string messagePrefix
where 
  // Check for regex patterns susceptible to exponential backtracking
  hasReDoSResult(term, repeatedString, state, messagePrefix)
  // Exclude verbose mode regex patterns (temporary mitigation)
  and not term.getRegex().getAMode() = "VERBOSE"
select term,
  // Generate alert message describing the vulnerability
  "This part of the regular expression may cause exponential backtracking on strings " + 
  messagePrefix + "containing many repetitions of '" + repeatedString + "'."