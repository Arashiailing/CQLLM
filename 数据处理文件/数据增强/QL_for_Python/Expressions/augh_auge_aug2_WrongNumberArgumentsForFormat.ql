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
 * @param formatOp - The binary expression containing the formatting operation
 * @param fmtStr - The format string literal
 * @param argValues - The values to be formatted
 * @param argSource - The AST node where the arguments originate
 */
predicate isPercentFormatOperation(BinaryExpr formatOp, StringLiteral fmtStr, Value argValues, AstNode argSource) {
  // Confirm modulo operator usage
  formatOp.getOp() instanceof Mod and
  exists(Context ctx |
    // Resolve left operand to format string literal
    formatOp.getLeft().pointsTo(ctx, _, fmtStr) and
    // Resolve right operand to argument values
    formatOp.getRight().pointsTo(ctx, argValues, argSource)
  )
}

/**
 * Computes the effective count of arguments in the sequence.
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
  BinaryExpr formatOp, StringLiteral fmtStr, Value argValues, 
  int argCount, int specifierCount, AstNode argSource, string messageSuffix
where
  // Identify percent-style formatting operations
  isPercentFormatOperation(formatOp, fmtStr, argValues, argSource) and
  // Compute provided argument count
  argCount = calculateArgumentCount(argValues) and
  // Count format specifiers in the string
  specifierCount = format_items(fmtStr) and
  // Detect argument count mismatch with format specifiers
  argCount != specifierCount and
  // Generate contextual message suffix
  (if argCount = 1 then messageSuffix = " is provided." else messageSuffix = " are provided.")
select formatOp,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    specifierCount.toString() + " values, but " + argCount.toString() + messageSuffix, 
  argSource, "arguments", fmtStr, fmtStr.getText()