/**
 * @name CWE-476: NULL Pointer Dereference
 * @description The product dereferences a pointer that it expects to be valid but is NULL.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.3
 * @sub-severity high
 * @precision medium
 * @id py/null-dereference
 * @tags correctness
 *       security
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContexts
import semmle.python.dataflow.new.DataFlow
import semmle.python.types.ApiGraphs

class Reference extends Expr {
  Reference() {
    this instanceof Attribute
    or
    this instanceof Subscript
    or
    this instanceof Name
    or
    this instanceof Starred
  }

  Expr getReferencePoint() { result = this.asExpr() }
}

class Access extends Expr {
  Access() {
    this instanceof Getattr
    or
    this instanceof Lookup
    or
    this instanceof IfExp
    or
    this instanceof If
    or
    this instanceof Compare
    or
    this instanceof Return
    or
    this instanceof Yield
    or
    this instanceof YieldFrom
    or
    this instanceof TryExcept
    or
    this instanceof Raise
    or
    this instanceof Assert
    or
    this instanceof Delete
    or
    this instanceof For
    or
    this instanceof While
    or
    this instanceof With
    or
    this instanceof Assign
    or
    this instanceof AugAssign
    or
    this instanceof Break
    or
    this instanceof Continue
    or
    this instanceof Pass
    or
    this instanceof Import
    or
    this instanceof ImportFrom
    or
    this instanceof Global
    or
    this instanceof Nonlocal
    or
    this instanceof Exec
    or
    this instanceof Print
    or
    this instanceof Backquote
    or
    this instanceof Decorate
    or
    this instanceof GenExpr
    or
    this instanceof DictComp
    or
    this instanceof SetComp
    or
    this instanceof ListComp
    or
    this instanceof Lambda
    or
    this instanceof Num
    or
    this instanceof Str
    or
    this instanceof Bytes
    or
    this instanceof NameConstant
    or
    this instanceof Ellipsis
    or
    this instanceof UnaryOp
    or
    this instanceof BinOp
    or
    this instanceof BoolOp
    or
    this instanceof Call
    or
    this instanceof GeneratorExp
  }

  Expr getAccessPoint() { result = this.asExpr() }
}

from ControlFlowNode origin, Reference ref, Access access
where
  exists(PointsToContext ctx |
    ref.pointsTo(ctx, origin) and
    access.getAccessPoint().getAFlowNode() = ref.getReferencePoint()
  )
select access, "This reference may depend on a $@.", origin, "null pointer"