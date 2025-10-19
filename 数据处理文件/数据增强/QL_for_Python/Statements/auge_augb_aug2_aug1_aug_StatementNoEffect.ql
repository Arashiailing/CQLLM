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
predicate attribute_is_well_defined(Attribute attribute, ClassValue sourceClass, ClassValue attributeClass) {
  exists(string attributeName | attribute.getName() = attributeName |
    attribute.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attributeName).getClass() = attributeClass
  )
}

/* Conservatively assesses whether an attribute access might produce side effects */
predicate attribute_has_side_effects(Attribute attribute) {
  exists(ClassValue attributeClass |
    attribute_is_well_defined(attribute, _, attributeClass) and
    descriptor_type_has_side_effects(attributeClass)
  )
}

// Identifies attributes that could potentially have side effects
predicate attribute_might_have_side_effects(Attribute attribute) {
  // Case 1: Attribute is not well-defined or doesn't point to a concrete value
  (not attribute_is_well_defined(attribute, _, _) and not attribute.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  attribute_has_side_effects(attribute)
}

// Evaluates if a descriptor type access results in side effects
predicate descriptor_type_has_side_effects(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // which we want to treat as having no effect
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

/**
 * Binary operators with side effects are uncommon, so we assume they have no side effects
 * unless we have evidence to the contrary
 */
predicate binary_expr_has_side_effects(Expr binaryExpression) {
  exists(Expr subExpression, ClassValue expressionClass, string specialMethodName |
    // Handle binary operator special methods
    (
      specialMethodName = binaryExpression.(BinaryExpr).getOp().getSpecialMethodName() and
      subExpression = binaryExpression.(BinaryExpr).getLeft() and
      subExpression.pointsTo().getClass() = expressionClass
    )
    or
    // Handle comparison operator special methods
    (
      exists(Cmpop op |
        binaryExpression.(Compare).compares(subExpression, op, _) and
        specialMethodName = op.getSpecialMethodName()
      ) and
      subExpression.pointsTo().getClass() = expressionClass
    )
  |
    specialMethodName = get_special_method_name() and
    expressionClass.hasAttribute(specialMethodName) and
    // Exclude inherited methods from built-in types (except object)
    not exists(ClassValue declaring |
      declaring.declaresAttribute(specialMethodName) and
      declaring = expressionClass.getASuperType() and
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

// Determines if a file is a Jupyter/IPython notebook
predicate file_is_notebook(File notebook) {
  exists(Comment notebookComment | notebookComment.getLocation().getFile() = notebook |
    notebookComment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is within a Jupyter/IPython notebook
predicate expression_in_notebook(Expr expression) { 
  file_is_notebook(expression.getScope().(Module).getFile()) 
}

// Retrieves the FunctionValue for unittest.TestCase's assertRaises method
FunctionValue get_unittest_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is within a `with` block that tests exception raising
predicate expression_in_raises_test(Expr expression) {
  exists(With withStatement |
    withStatement.contains(expression) and
    withStatement.getContextExpr() = get_unittest_assert_raises_method().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement (e.g., print >> out, ...)
predicate is_python2_print_expression(Expr expression) {
  // Handle print >> syntax
  (expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expression.(BinaryExpr).getOp() instanceof RShift)
  or
  // Recursively handle first element in tuple
  is_python2_print_expression(expression.(Tuple).getElt(0))
}

// Helper predicate to check if an expression has side effects in its sub-expressions
predicate sub_expression_has_side_effects(Expr expression) {
  exists(Expr subExpression | subExpression = expression.getASubExpression*() |
    binary_expr_has_side_effects(subExpression) or
    attribute_might_have_side_effects(subExpression)
  )
}

// Helper predicate to check if an expression is in a special context where it might be intentionally ineffectual
predicate expression_in_special_context(Expr expression) {
  expression_in_notebook(expression) or
  expression_in_raises_test(expression) or
  is_python2_print_expression(expression)
}

// Determines if an expression has no effect
predicate expression_is_ineffectual(Expr expression) {
  // String literals can serve as comments
  not expression instanceof StringLiteral and
  not expression.hasSideEffects() and
  // Check all sub-expressions
  not sub_expression_has_side_effects(expression) and
  // Exclude special cases
  not expression_in_special_context(expression)
}

// Select statements with no effect and report the issue
from ExprStmt stmt
where expression_is_ineffectual(stmt.getValue())
select stmt, "This statement has no effect."