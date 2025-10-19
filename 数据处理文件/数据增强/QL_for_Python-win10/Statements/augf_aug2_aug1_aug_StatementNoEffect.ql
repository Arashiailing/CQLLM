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

/* Determines if an attribute access is well-defined by examining its source and target classes */
predicate is_attribute_understood(Attribute attributeAccess, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attributeName | attributeAccess.getName() = attributeName |
    attributeAccess.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attributeName).getClass() = attrCls
  )
}

/* Checks if an attribute access could potentially cause side effects */
predicate has_side_effecting_attr(Attribute attributeAccess) {
  exists(ClassValue attrCls |
    is_attribute_understood(attributeAccess, _, attrCls) and
    is_descriptor_type_side_effecting(attrCls)
  )
}

// Determines if an attribute access might have side effects
predicate might_have_side_effect_attr(Attribute attributeAccess) {
  // Case 1: Attribute is not understood or doesn't point to a concrete value
  (not is_attribute_understood(attributeAccess, _, _) and not attributeAccess.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  has_side_effecting_attr(attributeAccess)
}

// Evaluates if a descriptor type has side effects when accessed
predicate is_descriptor_type_side_effecting(ClassValue descriptorCls) {
  descriptorCls.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // which we treat as having no effect
  not descriptorCls = ClassValue::functionType() and
  not descriptorCls = ClassValue::staticmethod() and
  not descriptorCls = ClassValue::classmethod()
}

/**
 * Binary operators rarely have side effects, so we assume they have no side effects
 * unless there's evidence to the contrary
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
predicate is_notebook_file(File notebook) {
  exists(Comment comment | comment.getLocation().getFile() = notebook |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is located within a Jupyter/IPython notebook
predicate expr_in_notebook(Expr expr) { 
  is_notebook_file(expr.getScope().(Module).getFile()) 
}

// Retrieves the FunctionValue for unittest.TestCase's assertRaises method
FunctionValue get_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is within a `with` block that tests exception raising
predicate expr_in_raises_test(Expr expr) {
  exists(With withStatement |
    withStatement.contains(expr) and
    withStatement.getContextExpr() = get_assert_raises_method().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement (e.g., print >> out, ...)
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
  // String literals can serve as documentation
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