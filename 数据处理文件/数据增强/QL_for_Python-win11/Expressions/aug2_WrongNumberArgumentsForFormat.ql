/**
 * @name Wrong number of arguments for format
 * @description Detects string formatting operations where the number of conversion specifiers 
 *              in the format string differs from the number of values to be formatted. 
 *              This will raise a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/percent-format/wrong-arguments
 */

import python
import semmle.python.strings

/**
 * Identifies string formatting operations using the % operator.
 * @param expr - The binary expression containing the formatting operation
 * @param fmtLiteral - The format string literal
 * @param argValues - The values to be formatted
 * @param argOrigin - The AST node where the arguments originate
 */
predicate isPercentFormatOperation(BinaryExpr expr, StringLiteral fmtLiteral, Value argValues, AstNode argOrigin) {
  // Verify the operator is modulo (%)
  expr.getOp() instanceof Mod and
  exists(Context ctx |
    // Trace the left operand to the format string literal
    expr.getLeft().pointsTo(ctx, _, fmtLiteral) and
    // Trace the right operand to the argument values
    expr.getRight().pointsTo(ctx, argValues, argOrigin)
  )
}

/**
 * Calculates the effective length of the argument sequence.
 * @param argValues - The value representing the arguments
 * @return The number of arguments in the sequence
 */
int calculateArgumentCount(Value argValues) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple tuple | tuple.pointsTo(argValues, _) |
    result = strictcount(tuple.getAnElt()) and
    not tuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral lit | lit.getLiteralValue() = argValues | result = 1)
}

from
  BinaryExpr formattingExpr, StringLiteral formatStr, Value argumentValues, 
  int argumentCount, int formatSpecCount, AstNode argumentOrigin, string messageSuffix
where
  // Identify percent-style formatting operations
  isPercentFormatOperation(formattingExpr, formatStr, argumentValues, argumentOrigin) and
  // Calculate the number of provided arguments
  argumentCount = calculateArgumentCount(argumentValues) and
  // Count the format specifiers in the string
  formatSpecCount = format_items(formatStr) and
  // Detect mismatch between argument count and format specifiers
  argumentCount != formatSpecCount and
  // Generate appropriate message suffix based on argument count
  (if argumentCount = 1 then messageSuffix = " is provided." else messageSuffix = " are provided.")
select formattingExpr,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    formatSpecCount.toString() + " values, but " + argumentCount.toString() + messageSuffix, 
  argumentOrigin, "arguments", formatStr, formatStr.getText()