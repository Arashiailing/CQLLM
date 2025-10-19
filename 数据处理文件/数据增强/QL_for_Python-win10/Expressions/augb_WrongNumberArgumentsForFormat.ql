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
predicate format_operation(BinaryExpr expr, StringLiteral fmt, Value args, AstNode source) {
  // Verify the operator is modulo (%)
  expr.getOp() instanceof Mod and
  exists(Context ctx |
    // Check left operand points to the format string
    expr.getLeft().pointsTo(ctx, _, fmt) and
    // Check right operand points to the argument value
    expr.getRight().pointsTo(ctx, args, source)
  )
}

// Calculates the length of the argument sequence
int argument_count(Value args) {
  /* Handle tuple arguments */
  exists(Tuple tuple | tuple.pointsTo(args, _) |
    result = strictcount(tuple.getAnElt()) and
    // Exclude starred expressions from count
    not tuple.getAnElt() instanceof Starred
  )
  or
  /* Handle single literal arguments */
  exists(ImmutableLiteral literal | literal.getLiteralValue() = args | result = 1)
}

from
  BinaryExpr formatExpr, StringLiteral formatStr, Value argValue, 
  int argCount, int formatItemCount, AstNode argSource, string messageSuffix
where
  // Identify format operation
  format_operation(formatExpr, formatStr, argValue, argSource) and
  // Calculate argument count
  argCount = argument_count(argValue) and
  // Calculate format item count
  formatItemCount = format_items(formatStr) and
  // Validate mismatch
  argCount != formatItemCount and
  // Generate appropriate message suffix
  (if argCount = 1 then messageSuffix = " is provided." else messageSuffix = " are provided.")
select formatExpr,
  // Construct error message
  "Wrong number of $@ for string format. Format $@ takes " + formatItemCount.toString() + 
  ", but " + argCount.toString() + messageSuffix, 
  argSource, "arguments", formatStr, formatStr.getText()