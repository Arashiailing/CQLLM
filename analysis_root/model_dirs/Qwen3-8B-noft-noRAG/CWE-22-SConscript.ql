import python

/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @id py/SConscript
 */

from PathExpression pe, Literal lit, Expr expr
where pe.getKind() = "path" and
      pe.hasLiteral(lit) and
      lit.getText() = ".." or
      lit.getText() = "." or
      lit.getText() = "~" or
      lit.getText() = "/" and
      expr.isVariable() and
      expr.getParent().getKind() = "binary_op" and
      expr.getParent().getOperator() = "+"
select expr, "Uncontrolled data used in path expression: potential path traversal."