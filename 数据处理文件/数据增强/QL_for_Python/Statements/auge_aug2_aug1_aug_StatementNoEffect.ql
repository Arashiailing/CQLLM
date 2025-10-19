/**
 * @name Statement has no effect
 * @description Identifies statements that produce no observable effect during program execution
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

/* Verifies if an attribute access is well-defined with clear source and target types */
predicate is_attribute_understood(Attribute attrNode, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attrName).getClass() = attrCls
  )
}

/* Determines if a descriptor type causes side effects when accessed */
predicate is_descriptor_type_side_effecting(ClassValue descCls) {
  descCls.isDescriptorType() and
  // All descriptor accesses have side effects, but we exclude certain missing-call cases
  not descCls = ClassValue::functionType() and
  not descCls = ClassValue::staticmethod() and
  not descCls = ClassValue::classmethod()
}

/* Conservatively identifies attributes that may trigger side effects */
predicate has_side_effecting_attr(Attribute attrNode) {
  exists(ClassValue attrCls |
    is_attribute_understood(attrNode, _, attrCls) and
    is_descriptor_type_side_effecting(attrCls)
  )
}

/* Flags attributes that could potentially cause side effects */
predicate might_have_side_effect_attr(Attribute attrNode) {
  // Case 1: Attribute is undefined or points to no concrete value
  (not is_attribute_understood(attrNode, _, _) and not attrNode.pointsTo(_))
  or
  // Case 2: Attribute is known to have side effects
  has_side_effecting_attr(attrNode)
}

/* Retrieves special method names for binary/comparison operators */
private string get_special_method_name() {
  result = any(Cmpop comparisonOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryExpr).getOp().getSpecialMethodName()
}

/* Identifies binary expressions using special operator methods */
pragma[nomagic]
private predicate is_special_binary_operator(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprCls, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprCls
}

/* Identifies comparison expressions using special operator methods */
pragma[nomagic]
private predicate is_special_comparison_operator(Compare compareExpr, Expr subExpr, ClassValue exprCls, string methodName) {
  exists(Cmpop op |
    compareExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprCls
}

/**
 * Binary operators rarely have side effects; we assume no effect unless proven otherwise
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

/* Checks if a file is a Jupyter/IPython notebook */
predicate is_notebook_file(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/* Determines if an expression resides within a Jupyter/IPython notebook */
predicate expr_in_notebook(Expr expr) { 
  is_notebook_file(expr.getScope().(Module).getFile()) 
}

/* Retrieves unittest.TestCase's assertRaises method */
FunctionValue get_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/* Checks if an expression is inside a `with` block testing exception raising */
predicate expr_in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = get_assert_raises_method().getACall().getNode()
  )
}

/* Identifies Python 2 print statements (e.g., print >> out, ...) */
predicate is_python2_print_stmt(Expr expr) {
  // Handle print >> syntax
  (expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expr.(BinaryExpr).getOp() instanceof RShift)
  or
  // Recursively handle first element in tuple
  is_python2_print_stmt(expr.(Tuple).getElt(0))
}

/* Determines if an expression produces no observable effect */
predicate expression_has_no_effect(Expr expr) {
  // String literals can serve as documentation
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Verify all sub-expressions
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