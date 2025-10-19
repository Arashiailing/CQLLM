/**
 * @name Incorrect argument count in string formatting
 * @description Identifies string formatting operations that have a mismatch between the number 
 *              of conversion specifiers in the format string and the number of values provided 
 *              for formatting. Such mismatches result in TypeError exceptions at runtime.
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
 * Identifies string formatting expressions using the % operator.
 * @param fmtOperation - The binary expression representing the formatting operation
 * @param fmtStringLiteral - The literal string used as the format template
 * @param fmtArguments - The collection of values to be formatted
 * @param argsOrigin - The AST node from which the arguments originate
 */
predicate detectPercentFormatOperation(BinaryExpr fmtOperation, StringLiteral fmtStringLiteral, Value fmtArguments, AstNode argsOrigin) {
  // Verify the operator is the modulo symbol (%)
  fmtOperation.getOp() instanceof Mod and
  exists(Context evalCtx |
    // Connect the left operand to the format string literal
    fmtOperation.getLeft().pointsTo(evalCtx, _, fmtStringLiteral) and
    // Connect the right operand to the argument values
    fmtOperation.getRight().pointsTo(evalCtx, fmtArguments, argsOrigin)
  )
}

/**
 * Computes the actual count of arguments in the argument sequence.
 * @param argsValue - The value representing the arguments
 * @return The number of arguments within the sequence
 */
int computeArgumentCount(Value argsValue) {
  // Handle tuple-type arguments (excluding starred expressions)
  exists(Tuple argsTuple | argsTuple.pointsTo(argsValue, _) |
    result = strictcount(argsTuple.getAnElt()) and
    not argsTuple.getAnElt() instanceof Starred
  )
  or
  // Handle individual literal arguments
  exists(ImmutableLiteral singleArg | singleArg.getLiteralValue() = argsValue | result = 1)
}

from
  BinaryExpr fmtExpr, StringLiteral fmtStr, Value argValues, 
  int suppliedArgsCount, int requiredArgsCount, AstNode argsOrigin, string pluralMarker
where
  // Identify percent-style formatting operations
  detectPercentFormatOperation(fmtExpr, fmtStr, argValues, argsOrigin) and
  // Calculate the number of provided arguments
  suppliedArgsCount = computeArgumentCount(argValues) and
  // Count the format specifiers in the template string
  requiredArgsCount = format_items(fmtStr) and
  // Detect mismatch between argument count and format specifiers
  suppliedArgsCount != requiredArgsCount and
  // Generate appropriate message suffix based on argument count
  (if suppliedArgsCount = 1 then pluralMarker = " is provided." else pluralMarker = " are provided.")
select fmtExpr,
  "Incorrect number of $@ for string formatting. Format $@ expects " + 
    requiredArgsCount.toString() + " values, but " + suppliedArgsCount.toString() + pluralMarker, 
  argsOrigin, "arguments", fmtStr, fmtStr.getText()