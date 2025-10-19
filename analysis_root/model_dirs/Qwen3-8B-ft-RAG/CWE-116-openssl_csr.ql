/**
 * @name Bad HTML filtering regexp
 * @description Matching HTML tags using regular expressions is hard to do right, and can easily lead to security issues.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/bad-tag-filter
 * @tags correctness
 *       security
 *       external/cwe/cwe-116
 */

import python
import semmle.python.security.dataflow.XpathInjectionQuery
import XpathInjectionFlow::PathGraph