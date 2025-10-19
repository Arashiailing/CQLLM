/**
 * @name Incorrect argument count for percent-formatting
 * @description Identifies string formatting operations where the quantity of format specifiers 
 *              in the template string mismatches the supplied argument count, leading to 
 *              runtime TypeError exceptions.
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
 * Detects string formatting operations using the % operator.
 * Establishes relationships between the formatting expression, template string, 
 * arguments, and their source location.
 */
predicate percentFormatOperation(BinaryExpr fmtExpr, StringLiteral templateStr, 
                                Value argValues, AstNode argOrigin) {
  // Verify modulo operator usage for string formatting
  fmtExpr.getOp() instanceof Mod and
  exists(Context ctx |
    // Link left operand to template string literal
    fmtExpr.getLeft().pointsTo(ctx, _, templateStr) and
    // Link right operand to provided arguments
    fmtExpr.getRight().pointsTo(ctx, argValues, argOrigin)
  )
}

/**
 * Computes the effective argument count for formatting operations.
 * Handles various argument container types including tuples and literals.
 */
int countFormatArguments(Value argValues) {
  // Tuple argument handling
  exists(Tuple argTuple | argTuple.pointsTo(argValues, _) |
    result = strictcount(argTuple.getAnElt()) and
    // Exclude starred expressions (*args) from element count
    not argTuple.getAnElt() instanceof Starred
  )
  or
  // Single literal argument handling
  exists(ImmutableLiteral lit | lit.getLiteralValue() = argValues | result = 1)
}

from
  BinaryExpr fmtExpr, StringLiteral templateStr, Value argValues, 
  int argCount, int specCount, AstNode argOrigin, string pluralSuffix
where
  // Identify percent-formatting operations
  percentFormatOperation(fmtExpr, templateStr, argValues, argOrigin) and
  // Calculate provided argument count
  argCount = countFormatArguments(argValues) and
  // Determine format specifier count in template
  specCount = format_items(templateStr) and
  // Detect argument-specifier count mismatch
  argCount != specCount and
  // Generate plural-sensitive suffix
  (if argCount = 1 then pluralSuffix = " is provided." else pluralSuffix = " are provided.")
select fmtExpr,
  // Construct detailed error message
  "Incorrect $@ count for percent-format. Template $@ requires " + specCount.toString() + 
  " values, but " + argCount.toString() + pluralSuffix, 
  argOrigin, "arguments", templateStr, templateStr.getText()