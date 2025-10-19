/**
 * @name Wrong number of arguments for format
 * @description Detects string formatting operations where the number of conversion specifiers 
 *              in the format string doesn't match the number of provided values. 
 *              Example: '"%s: %s, %s" % (a,b)' will raise a TypeError.
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

// Identifies string formatting operations using the % operator
predicate percent_format_operation(BinaryExpr binExpr, StringLiteral fmtLiteral, Value argValue, AstNode argSrcNode) {
  // Verify the operator is modulo (%)
  binExpr.getOp() instanceof Mod and
  exists(Context ctx |
    // Check left operand points to the format string
    binExpr.getLeft().pointsTo(ctx, _, fmtLiteral) and
    // Check right operand points to the argument value
    binExpr.getRight().pointsTo(ctx, argValue, argSrcNode)
  )
}

// Calculates the length of the argument sequence
int calculate_argument_count(Value argVal) {
  /* Handle tuple arguments */
  exists(Tuple argTuple | argTuple.pointsTo(argVal, _) |
    result = strictcount(argTuple.getAnElt()) and
    // Exclude starred expressions from count
    not argTuple.getAnElt() instanceof Starred
  )
  or
  /* Handle single literal arguments */
  exists(ImmutableLiteral argLiteral | argLiteral.getLiteralValue() = argVal | result = 1)
}

from
  BinaryExpr fmtOp, StringLiteral fmtStr, Value argVal, 
  int providedCount, int expectedCount, AstNode argSrc, string msgSuffix
where
  // Identify format operation
  percent_format_operation(fmtOp, fmtStr, argVal, argSrc) and
  // Calculate argument count
  providedCount = calculate_argument_count(argVal) and
  // Calculate format item count
  expectedCount = format_items(fmtStr) and
  // Validate mismatch
  providedCount != expectedCount and
  // Generate appropriate message suffix
  (if providedCount = 1 then msgSuffix = " is provided." else msgSuffix = " are provided.")
select fmtOp,
  // Construct error message
  "Wrong number of $@ for string format. Format $@ takes " + expectedCount.toString() + 
  ", but " + providedCount.toString() + msgSuffix, 
  argSrc, "arguments", fmtStr, fmtStr.getText()