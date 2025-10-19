/**
 * @name Statement has no effect
 * @description Identifies statements that have no effect (dead code)
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/ineffectual-statement
 */

import python

// Helper to determine if an attribute access is well-understood
predicate is_well_understood_attr(Attribute attrNode, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attrName).getClass() = attrCls
  )
}

// Conservative check for side-effecting attribute access
predicate is_side_effecting_attr(Attribute attrNode) {
  exists(ClassValue attrCls |
    is_well_understood_attr(attrNode, _, attrCls) and
    is_side_effecting_descriptor_type(attrCls)
  )
}

// Check for potentially side-effecting attribute access
predicate is_potentially_side_effecting_attr(Attribute attrNode) {
  not is_well_understood_attr(attrNode, _, _) and not attrNode.pointsTo(_)
  or
  is_side_effecting_attr(attrNode)
}

// Determine if a descriptor type has side effects
predicate is_side_effecting_descriptor_type(ClassValue descCls) {
  descCls.isDescriptorType() and
  // Technically all descriptor accesses have side effects, but we exclude common harmless ones
  not descCls = ClassValue::functionType() and
  not descCls = ClassValue::staticmethod() and
  not descCls = ClassValue::classmethod()
}

// Get special method names for operators and comparisons
private string get_special_method_name() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

pragma[nomagic]
private predicate is_bin_op_special_method(
  BinaryExpr binExpr, Expr subExpr, ClassValue sourceCls, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binExpr.getLeft() and
  methodName = binExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = sourceCls
}

pragma[nomagic]
private predicate is_cmp_special_method(Compare cmpExpr, Expr subExpr, ClassValue sourceCls, string methodName) {
  exists(Cmpop op |
    cmpExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = sourceCls
}

/**
 * Most binary operations are side-effect free, but we check for exceptions
 */
predicate is_side_effecting_binary(Expr binExpr) {
  exists(Expr subExpr, ClassValue sourceCls, string methodName |
    is_bin_op_special_method(binExpr, subExpr, sourceCls, methodName)
    or
    is_cmp_special_method(binExpr, subExpr, sourceCls, methodName)
  |
    methodName = get_special_method_name() and
    sourceCls.hasAttribute(methodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = sourceCls.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Check if file is a Jupyter/IPython notebook
predicate is_notebook_file(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Check if expression is in a Jupyter/IPython notebook */
predicate is_in_notebook(Expr expr) { 
  is_notebook_file(expr.getScope().(Module).getFile()) 
}

// Get unittest.TestCase's assertRaises method
FunctionValue get_unittest_assert_raises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** Check if expression is in a unittest assertRaises context */
predicate is_in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = get_unittest_assert_raises().getACall().getNode()
  )
}

/** Check for Python 2 print statements (print >> out, ...) */
predicate is_python2_print(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  is_python2_print(expr.(Tuple).getElt(0))
}

// Core predicate to identify expressions with no effect
predicate is_no_effect_expression(Expr expr) {
  // Strings can be used as docstrings/comments
  (not expr instanceof StringLiteral and not expr.hasSideEffects()) and
  // Ensure all sub-expressions are side-effect free
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    (not is_side_effecting_binary(subExpr) and not is_potentially_side_effecting_attr(subExpr))
  ) and
  // Exclude special contexts where expressions are expected
  (not is_in_notebook(expr) and not is_in_raises_test(expr) and not is_python2_print(expr))
}

// Main query to find and report ineffectual statements
from ExprStmt stmt
where is_no_effect_expression(stmt.getValue())
select stmt, "This statement has no effect."