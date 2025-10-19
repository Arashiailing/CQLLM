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

/* 
 * Determines if an attribute is properly defined by checking if its source class
 * contains the attribute and it points to the expected attribute class
 */
predicate attribute_is_well_defined(Attribute attrNode, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attrName).getClass() = attrCls
  )
}

/* 
 * Conservatively determines if an attribute access might produce side effects
 * by checking if it's a well-defined descriptor type with potential side effects
 */
predicate attribute_has_side_effects(Attribute attrNode) {
  exists(ClassValue attrCls |
    attribute_is_well_defined(attrNode, _, attrCls) and
    descriptor_type_has_side_effects(attrCls)
  )
}

// Identifies attributes that could potentially have side effects
predicate attribute_might_have_side_effects(Attribute attrNode) {
  // Case 1: Attribute is not well-defined or doesn't point to a concrete value
  (not attribute_is_well_defined(attrNode, _, _) and not attrNode.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  attribute_has_side_effects(attrNode)
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
  exists(Expr subExpr, ClassValue exprCls, string specialMethodName |
    // Handle binary operator special methods
    (
      specialMethodName = binaryExpr.(BinaryExpr).getOp().getSpecialMethodName() and
      subExpr = binaryExpr.(BinaryExpr).getLeft() and
      subExpr.pointsTo().getClass() = exprCls
    )
    or
    // Handle comparison operator special methods
    (
      exists(Cmpop op |
        binaryExpr.(Compare).compares(subExpr, op, _) and
        specialMethodName = op.getSpecialMethodName()
      ) and
      subExpr.pointsTo().getClass() = exprCls
    )
  |
    specialMethodName = get_special_method_name() and
    exprCls.hasAttribute(specialMethodName) and
    // Exclude inherited methods from built-in types (except object)
    not exists(ClassValue declaring |
      declaring.declaresAttribute(specialMethodName) and
      declaring = exprCls.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Retrieves the special method name for comparison or binary operators
private string get_special_method_name() {
  result = any(Cmpop comparisonOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryExpr).getOp().getSpecialMethodName()
}

// Determines if a file is a Jupyter/IPython notebook by checking for nbformat comment
predicate file_is_notebook(File notebookFile) {
  exists(Comment nbComment | nbComment.getLocation().getFile() = notebookFile |
    nbComment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
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

// Helper predicate to check if an expression has side effects in its sub-expressions
predicate sub_expression_has_side_effects(Expr expr) {
  exists(Expr subExpr | subExpr = expr.getASubExpression*() |
    binary_expr_has_side_effects(subExpr) or
    attribute_might_have_side_effects(subExpr)
  )
}

// Helper predicate to check if an expression is in a special context where it might be intentionally ineffectual
predicate expression_in_special_context(Expr expr) {
  expression_in_notebook(expr) or
  expression_in_raises_test(expr) or
  is_python2_print_expression(expr)
}

// Determines if an expression has no effect
predicate expression_is_ineffectual(Expr expr) {
  // String literals can serve as comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions
  not sub_expression_has_side_effects(expr) and
  // Exclude special cases
  not expression_in_special_context(expr)
}

// Select statements with no effect and report the issue
from ExprStmt ineffectualStmt
where expression_is_ineffectual(ineffectualStmt.getValue())
select ineffectualStmt, "This statement has no effect."