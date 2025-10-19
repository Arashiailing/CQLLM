/**
 * @name NotImplemented is not an Exception
 * @description Detects when 'NotImplemented' is raised instead of 'NotImplementedError', which leads to type errors.
 * @kind problem
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raise-not-implemented
 * @tags reliability
 *       maintainability
 */

/**
 * This query identifies instances where 'NotImplemented' is incorrectly used in raise statements.
 * 
 * Background:
 * - 'NotImplemented' is a special value in Python that methods can return to indicate
 *   that the operation is not implemented for the given arguments.
 * - 'NotImplementedError' is the actual exception that should be raised when a method
 *   or function has not been implemented yet.
 * 
 * Using 'NotImplemented' in a raise statement leads to type errors because it's not
 * an exception class but a special value, which can cause unexpected behavior and
 * make debugging more difficult.
 */

// Import core Python analysis functionality
import python

// Import specialized module for NotImplemented exception analysis
import Exceptions.NotImplemented

// Find expressions that incorrectly use NotImplemented in raise statements
from Expr incorrectNotImplementedUsage
where 
  // The expression represents a NotImplemented usage in a raise context
  use_of_not_implemented_in_raise(_, incorrectNotImplementedUsage)
  
// Output the problematic expression with suggested correction
select incorrectNotImplementedUsage, "NotImplemented is not an Exception. Did you mean NotImplementedError?"