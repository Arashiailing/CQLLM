/**
 * @name Statement has no effect
 * @description Identifies statements that have no effect during program execution
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

// Determines if an attribute is well-understood in terms of its source and target classes
predicate is_attribute_understood(Attribute attr, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attrName | attr.getName() = attrName |
    attr.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attrName).getClass() = attrCls
  )
}

/* Conservatively determines if attribute access might have side effects */
predicate has_side_effecting_attr(Attribute attr) {
  exists(ClassValue attrCls |
    is_attribute_understood(attr, _, attrCls) and
    is_descriptor_type_side_effecting(attrCls)
  )
}

// Identifies attributes that might potentially have side effects
predicate might_have_side_effect_attr(Attribute attr) {
  // Case 1: Attribute is not understood or doesn't point to a concrete value
  (not is_attribute_understood(attr, _, _) and not attr.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  has_side_effecting_attr(attr)
}

// Checks if a descriptor type has side effects when accessed
predicate is_descriptor_type_side_effecting(ClassValue descriptorCls) {
  descriptorCls.isDescriptorType() and
  // Technically all descriptor accesses have side effects, but some represent missing calls
  // which we want to treat as having no effect
  not descriptorCls = ClassValue::functionType() and
  not descriptorCls = ClassValue::staticmethod() and
  not descriptorCls = ClassValue::classmethod()
}

/**
 * Binary operators with side effects are rare, so we assume they have no side effects
 * unless we know otherwise
 */
predicate is_binary_side_effecting(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue exprCls, string methodName |
    // Handle binary operator special methods
    is_special_binary_operator(binaryExpr, subExpr, exprCls, methodName)
    or
    // Handle comparison operator special methods
    is_special_comparison_operator(binaryExpr, subExpr, exprCls, methodName)
  |
    methodName = get_special_method_name() and
    exprCls.hasAttribute(methodName) and
    // Exclude inherited methods from built-in types (except object)
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = exprCls.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

pragma[nomagic]
private predicate is_special_binary_operator(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprCls, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprCls
}

pragma[nomagic]
private predicate is_special_comparison_operator(Compare binaryExpr, Expr subExpr, ClassValue exprCls, string methodName) {
  exists(Cmpop op |
    binaryExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprCls
}

private string get_special_method_name() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Determines if a file is a Jupyter/IPython notebook
predicate is_notebook_file(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Expressions (statements) within Jupyter/IPython notebooks */
predicate expr_in_notebook(Expr expr) { 
  is_notebook_file(expr.getScope().(Module).getFile()) 
}

// Retrieves the FunctionValue object for unittest.TestCase's assertRaises method
FunctionValue get_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** True if expression `expr` is within a `with` block that tests exception raising */
predicate expr_in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = get_assert_raises_method().getACall().getNode()
  )
}

/** True if expression has the form of Python 2 `print >> out, ...` statement */
predicate is_python2_print_stmt(Expr expr) {
  // Handle print >> syntax
  (expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expr.(BinaryExpr).getOp() instanceof RShift)
  or
  // Recursively handle first element in tuple
  is_python2_print_stmt(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate expression_has_no_effect(Expr expr) {
  // String literals can serve as comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not is_binary_side_effecting(subExpr) and
    not might_have_side_effect_attr(subExpr)
  ) and
  // Exclude special cases
  not expr_in_notebook(expr) and
  not expr_in_raises_test(expr) and
  not is_python2_print_stmt(expr)
}

// Select statements with no effect and report the issue
from ExprStmt stmt
where expression_has_no_effect(stmt.getValue())
select stmt, "This statement has no effect."