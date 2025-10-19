/**
 * @name Statement has no effect
 * @description Identifies statements that do not produce any effect during program execution
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

/* Determines whether an attribute is properly defined based on its source and target classes */
predicate attribute_is_well_defined(Attribute attr, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attrName | attr.getName() = attrName |
    attr.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attrName).getClass() = attrCls
  )
}

/* Conservatively assesses whether an attribute access might produce side effects */
predicate attribute_has_side_effects(Attribute attr) {
  exists(ClassValue attrCls |
    attribute_is_well_defined(attr, _, attrCls) and
    descriptor_type_has_side_effects(attrCls)
  )
}

// Identifies attributes that could potentially have side effects
predicate attribute_might_have_side_effects(Attribute attr) {
  // Case 1: Attribute is not well-defined or doesn't point to a concrete value
  (not attribute_is_well_defined(attr, _, _) and not attr.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  attribute_has_side_effects(attr)
}

// Evaluates if a descriptor type access results in side effects
predicate descriptor_type_has_side_effects(ClassValue descriptorCls) {
  descriptorCls.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // which we want to treat as having no effect
  not descriptorCls = ClassValue::functionType() and
  not descriptorCls = ClassValue::staticmethod() and
  not descriptorCls = ClassValue::classmethod()
}

/**
 * Binary operators with side effects are uncommon, so we assume they have no side effects
 * unless we have evidence to the contrary
 */
predicate binary_expr_has_side_effects(Expr binaryExpr) {
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

// Identifies binary expressions that utilize special operator methods
pragma[nomagic]
private predicate is_special_binary_operator(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprCls, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprCls
}

// Identifies comparison expressions that utilize special operator methods
pragma[nomagic]
private predicate is_special_comparison_operator(Compare binaryExpr, Expr subExpr, ClassValue exprCls, string methodName) {
  exists(Cmpop op |
    binaryExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprCls
}

// Retrieves the special method name for comparison or binary operators
private string get_special_method_name() {
  result = any(Cmpop comparisonOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryExpr).getOp().getSpecialMethodName()
}

// Determines if a file is a Jupyter/IPython notebook
predicate file_is_notebook(File notebookFile) {
  exists(Comment comment | comment.getLocation().getFile() = notebookFile |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is within a Jupyter/IPython notebook
predicate expression_in_notebook(Expr expr) { 
  file_is_notebook(expr.getScope().(Module).getFile()) 
}

// Retrieves the FunctionValue for unittest.TestCase's assertRaises method
FunctionValue get_unittest_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is within a `with` block that tests exception raising
predicate expression_in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = get_unittest_assert_raises_method().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement (e.g., print >> out, ...)
predicate is_python2_print_expression(Expr expr) {
  // Handle print >> syntax
  (expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expr.(BinaryExpr).getOp() instanceof RShift)
  or
  // Recursively handle first element in tuple
  is_python2_print_expression(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate expression_is_ineffectual(Expr expr) {
  // String literals can serve as comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not binary_expr_has_side_effects(subExpr) and
    not attribute_might_have_side_effects(subExpr)
  ) and
  // Exclude special cases
  not expression_in_notebook(expr) and
  not expression_in_raises_test(expr) and
  not is_python2_print_expression(expr)
}

// Select statements with no effect and report the issue
from ExprStmt stmt
where expression_is_ineffectual(stmt.getValue())
select stmt, "This statement has no effect."