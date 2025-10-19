/**
 * @name CWE-863: Incorrect Authorization
 * @description The product performs an authorization check when an actor attempts to access a resource or perform an action, but it does not correctly perform the check.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id py/models
 */

import python
import semmle.python.models.Concepts.AuthorizationModels
import semmle.python.models.PamAuthorizationQuery