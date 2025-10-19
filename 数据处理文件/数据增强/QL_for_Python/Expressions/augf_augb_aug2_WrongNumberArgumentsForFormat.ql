/**
 * @name Wrong number of arguments for format
 * @description Detects string formatting operations using % operator where the number of 
 *              conversion specifiers in the format string mismatches the count of values 
 *              to be formatted, causing runtime TypeError.
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
 * Identifies % operator-based string formatting operations.
 * @param formatExpr - Binary expression containing the formatting operation
 * @param fmtLiteral - Format string literal
 * @param argsValue - Values to be formatted
 * @param argsOrigin - AST node providing the arguments
 */
predicate findPercentFormatOperation(BinaryExpr formatExpr, StringLiteral fmtLiteral, Value argsValue, AstNode argsOrigin) {
  // Verify modulo operator usage
  formatExpr.getOp() instanceof Mod and
  exists(Context evalCtx |
    // Resolve left operand to format string literal
    formatExpr.getLeft().pointsTo(evalCtx, _, fmtLiteral) and
    // Resolve right operand to argument values
    formatExpr.getRight().pointsTo(evalCtx, argsValue, argsOrigin)
  )
}

/**
 * Calculates the effective number of formatting arguments.
 * @param argSeq - Value representing the argument sequence
 * @return Count of arguments in the sequence
 */
int getArgumentCount(Value argSeq) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple argTuple | argTuple.pointsTo(argSeq, _) |
    result = strictcount(argTuple.getAnElt()) and
    not argTuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral singleArg | singleArg.getLiteralValue() = argSeq | result = 1)
}

from
  BinaryExpr formatOperation, StringLiteral formatString, Value argumentValues, 
  int actualArgCount, int requiredFormatCount, AstNode argumentSource, string msgSuffix
where
  // Locate percent-style formatting operations
  findPercentFormatOperation(formatOperation, formatString, argumentValues, argumentSource) and
  // Determine actual argument count
  actualArgCount = getArgumentCount(argumentValues) and
  // Count required format specifiers
  requiredFormatCount = format_items(formatString) and
  // Identify argument count mismatch
  actualArgCount != requiredFormatCount and
  // Generate context-aware message suffix
  (if actualArgCount = 1 then msgSuffix = " is provided." else msgSuffix = " are provided.")
select formatOperation,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    requiredFormatCount.toString() + " values, but " + actualArgCount.toString() + msgSuffix, 
  argumentSource, "arguments", formatString, formatString.getText()