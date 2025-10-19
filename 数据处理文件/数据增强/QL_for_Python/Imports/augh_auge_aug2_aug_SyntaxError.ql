/**
 * @name Syntax error
 * @description Identifies Python syntax errors causing runtime failures and hindering precise code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/syntax-error
 */

// Import core Python analysis components for syntax error detection
import python

// Source syntax errors excluding encoding-specific issues
from SyntaxError err
where not err instanceof EncodingError

// Output error details with version context
select err, err.getMessage() + " (in Python " + major_version() + ")."