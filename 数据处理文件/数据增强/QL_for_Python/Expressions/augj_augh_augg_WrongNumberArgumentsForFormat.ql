/**
 * @name Wrong number of arguments for format
 * @description Detects string formatting operations where the number of conversion specifiers 
 *              in the format string does not match the number of provided values, which would
 *              result in a TypeError at runtime.
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
 * Captures the relationship between the formatting operation, 
 * format string, arguments, and their source location.
 */
predicate formattingOperation(BinaryExpr formatExpr, StringLiteral formatString, 
                            Value formatArgs, AstNode argsSource) {
  exists(Context context |
    formatExpr.getOp() instanceof Mod and
    formatExpr.getLeft().pointsTo(context, _, formatString) and
    formatExpr.getRight().pointsTo(context, formatArgs, argsSource)
  )
}

/**
 * Computes the length of the argument sequence used in string formatting.
 * Handles tuples and single literals while excluding starred expressions.
 */
int argumentCount(Value formatArgs) {
  // Handle tuple arguments (excluding starred expressions)
  exists(Tuple tuple | tuple.pointsTo(formatArgs, _) |
    result = strictcount(tuple.getAnElt()) and
    not tuple.getAnElt() instanceof Starred
  )
  or
  // Handle single literal arguments
  exists(ImmutableLiteral literal | literal.getLiteralValue() = formatArgs | result = 1)
}

from
  BinaryExpr formatExpr, StringLiteral formatString, Value formatArgs, 
  int argCount, int specifierCount, AstNode argsSource, string pluralSuffix
where
  formattingOperation(formatExpr, formatString, formatArgs, argsSource) and
  argCount = argumentCount(formatArgs) and
  specifierCount = format_items(formatString) and
  argCount != specifierCount and
  (if argCount = 1 then pluralSuffix = " is provided." else pluralSuffix = " are provided.")
select formatExpr,
  "Wrong number of $@ for string format. Format $@ takes " + specifierCount.toString() + ", but " +
    argCount.toString() + pluralSuffix, argsSource, "arguments", formatString, formatString.getText()