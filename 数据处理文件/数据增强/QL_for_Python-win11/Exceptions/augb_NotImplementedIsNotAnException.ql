/**
 * @name NotImplemented is not an Exception
 * @description Detects incorrect usage of 'NotImplemented' as an exception in raise statements,
 *              which will cause a type error at runtime.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

// Import Python library for code analysis
import python

// Import the NotImplemented exception-related module
import Exceptions.NotImplemented

// Identify expressions that represent incorrect usage of NotImplemented in raise statements
from Expr notImplementedExpr
// Filter expressions to find those where NotImplemented is used in a raise context
where use_of_not_implemented_in_raise(_, notImplementedExpr)
// Select the problematic expression and provide a helpful warning message
select notImplementedExpr, "NotImplemented is not an Exception. Did you mean NotImplementedError?"