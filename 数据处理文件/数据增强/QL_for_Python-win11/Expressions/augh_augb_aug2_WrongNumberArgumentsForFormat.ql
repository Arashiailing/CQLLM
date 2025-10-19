/**
 * @name Wrong number of arguments for format
 * @description Identifies string formatting operations where the count of conversion specifiers 
 *              in the format string doesn't match the count of values to be formatted. 
 *              This results in a TypeError at runtime.
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
 * Locates string formatting operations using the % operator.
 * @param formattingExpr - Binary expression containing the formatting operation
 * @param formatStr - Format string literal
 * @param argsValue - Values to be formatted
 * @param argsOrigin - AST node where arguments originate
 */
predicate findPercentFormatOperation(BinaryExpr formattingExpr, StringLiteral formatStr, Value argsValue, AstNode argsOrigin) {
  // Verify modulo operator usage
  formattingExpr.getOp() instanceof Mod and
  exists(Context evalContext |
    // Resolve left operand to format string
    formattingExpr.getLeft().pointsTo(evalContext, _, formatStr) and
    // Resolve right operand to argument values
    formattingExpr.getRight().pointsTo(evalContext, argsValue, argsOrigin)
  )
}

/**
 * Determines the count of arguments in the formatting sequence.
 * @param argsValue - Value representing the arguments
 * @return Number of arguments in the sequence
 */
int getArgumentCount(Value argsValue) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple argsTuple | argsTuple.pointsTo(argsValue, _) |
    result = strictcount(argsTuple.getAnElt()) and
    not argsTuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral singleArgLiteral | singleArgLiteral.getLiteralValue() = argsValue | result = 1)
}

from
  BinaryExpr formattingOp, StringLiteral formatStrLiteral, Value argsForFormatting, 
  int actualArgCount, int expectedArgCount, AstNode argsOriginNode, string pluralMarker
where
  // Identify percent-style formatting operations
  findPercentFormatOperation(formattingOp, formatStrLiteral, argsForFormatting, argsOriginNode) and
  // Calculate provided argument count
  actualArgCount = getArgumentCount(argsForFormatting) and
  // Count format specifiers in string
  expectedArgCount = format_items(formatStrLiteral) and
  // Detect argument count mismatch
  actualArgCount != expectedArgCount and
  // Generate pluralization suffix
  (if actualArgCount = 1 then pluralMarker = " is provided." else pluralMarker = " are provided.")
select formattingOp,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    expectedArgCount.toString() + " values, but " + actualArgCount.toString() + pluralMarker, 
  argsOriginNode, "arguments", formatStrLiteral, formatStrLiteral.getText()