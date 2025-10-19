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
predicate formattingOperation(BinaryExpr expr, StringLiteral fmtStr, 
                            Value args, AstNode argsSrc) {
  expr.getOp() instanceof Mod and
  exists(Context ctx |
    expr.getLeft().pointsTo(ctx, _, fmtStr) and
    expr.getRight().pointsTo(ctx, args, argsSrc)
  )
}

/**
 * Computes the length of the argument sequence used in string formatting.
 * Handles tuples and single literals while excluding starred expressions.
 */
int argumentCount(Value args) {
  exists(Tuple t | t.pointsTo(args, _) |
    result = strictcount(t.getAnElt()) and
    not t.getAnElt() instanceof Starred
  )
  or
  exists(ImmutableLiteral lit | lit.getLiteralValue() = args | result = 1)
}

from
  BinaryExpr expr, StringLiteral fmtStr, Value args, 
  int argNum, int specNum, AstNode argsSrc, string plural
where
  formattingOperation(expr, fmtStr, args, argsSrc) and
  argNum = argumentCount(args) and
  specNum = format_items(fmtStr) and
  argNum != specNum and
  (if argNum = 1 then plural = " is provided." else plural = " are provided.")
select expr,
  "Wrong number of $@ for string format. Format $@ takes " + specNum.toString() + ", but " +
    argNum.toString() + plural, argsSrc, "arguments", fmtStr, fmtStr.getText()