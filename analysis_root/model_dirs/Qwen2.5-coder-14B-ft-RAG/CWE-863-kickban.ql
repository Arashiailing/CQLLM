/**
 * @name CWE-863: Incorrect Authorization
 * @description The product performs an authorization check when an actor attempts to access a resource or perform an action, but it does not correctly perform the check.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 8.1
 * @precision high
 * @id py/kickban
 * @tags security
 *       external/cwe/cwe-863
 */

import python
import PamAuthorizationFlow::PathGraph
import semmle.python.security.dataflow.PamAuthorizationQuery