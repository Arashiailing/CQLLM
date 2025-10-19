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
 * @param formatExpr - The binary expression containing the formatting operation
 * @param formatLiteral - The format string literal
 * @param argsValue - The values to be formatted
 * @param argsOrigin - The AST node where the arguments originate
 */
predicate isPercentFormatOperation(BinaryExpr formatExpr, StringLiteral formatLiteral, Value argsValue, AstNode argsOrigin) {
  // Verify the operator is modulo (%)
  formatExpr.getOp() instanceof Mod and
  exists(Context ctx |
    // Trace the left operand to the format string literal
    formatExpr.getLeft().pointsTo(ctx, _, formatLiteral) and
    // Trace the right operand to the argument values
    formatExpr.getRight().pointsTo(ctx, argsValue, argsOrigin)
  )
}

/**
 * Calculates the effective length of the argument sequence.
 * @param argsValue - The value representing the arguments
 * @return The number of arguments in the sequence
 */
int calculateArgumentCount(Value argsValue) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple tuple | tuple.pointsTo(argsValue, _) |
    result = strictcount(tuple.getAnElt()) and
    not tuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral lit | lit.getLiteralValue() = argsValue | result = 1)
}

from
  BinaryExpr formatExpr, StringLiteral formatLiteral, Value argsValue, 
  int argCount, int specCount, AstNode argsOrigin, string msgSuffix
where
  // Identify percent-style formatting operations
  isPercentFormatOperation(formatExpr, formatLiteral, argsValue, argsOrigin) and
  // Calculate the number of provided arguments
  argCount = calculateArgumentCount(argsValue) and
  // Count the format specifiers in the string
  specCount = format_items(formatLiteral) and
  // Detect mismatch between argument count and format specifiers
  argCount != specCount and
  // Generate appropriate message suffix based on argument count
  (if argCount = 1 then msgSuffix = " is provided." else msgSuffix = " are provided.")
select formatExpr,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    specCount.toString() + " values, but " + argCount.toString() + msgSuffix, 
  argsOrigin, "arguments", formatLiteral, formatLiteral.getText()