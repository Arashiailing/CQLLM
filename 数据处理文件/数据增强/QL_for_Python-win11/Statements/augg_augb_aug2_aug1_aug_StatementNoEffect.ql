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

/* Evaluates if an attribute is properly defined between source and target classes */
predicate is_properly_defined_attribute(Attribute attr, ClassValue sourceClass, ClassValue attributeClass) {
  exists(string attributeName | attr.getName() = attributeName |
    attr.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attributeName).getClass() = attributeClass
  )
}

/* Determines if an attribute access could potentially cause side effects */
predicate causes_side_effects(Attribute attr) {
  exists(ClassValue attributeClass |
    is_properly_defined_attribute(attr, _, attributeClass) and
    descriptor_has_side_effects(attributeClass)
  )
}

// Identifies attributes that might have side effects during execution
predicate might_cause_side_effects(Attribute attr) {
  // Case 1: Attribute is not properly defined or doesn't reference a concrete value
  (not is_properly_defined_attribute(attr, _, _) and not attr.pointsTo(_))
  or
  // Case 2: Attribute is already identified as causing side effects
  causes_side_effects(attr)
}

// Checks if accessing a descriptor type results in side effects
predicate descriptor_has_side_effects(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // which we want to treat as having no effect
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

/**
 * Binary operators typically don't have side effects, so we assume they are safe
 * unless proven otherwise
 */
predicate binary_operation_has_side_effects(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue exprClass, string specialMethodName |
    // Handle binary operator special methods
    uses_special_binary_operator(binaryExpr, subExpr, exprClass, specialMethodName)
    or
    // Handle comparison operator special methods
    uses_special_comparison_operator(binaryExpr, subExpr, exprClass, specialMethodName)
  |
    specialMethodName = get_special_method_name() and
    exprClass.hasAttribute(specialMethodName) and
    // Exclude inherited methods from built-in types (except object)
    not exists(ClassValue declaringClass |
      declaringClass.declaresAttribute(specialMethodName) and
      declaringClass = exprClass.getASuperType() and
      declaringClass.isBuiltin() and
      not declaringClass = ClassValue::object()
    )
  )
}

// Identifies binary expressions that use special operator methods
pragma[nomagic]
private predicate uses_special_binary_operator(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprClass, string specialMethodName
) {
  specialMethodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  specialMethodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprClass
}

// Identifies comparison expressions that use special operator methods
pragma[nomagic]
private predicate uses_special_comparison_operator(Compare binaryExpr, Expr subExpr, ClassValue exprClass, string specialMethodName) {
  exists(Cmpop op |
    binaryExpr.compares(subExpr, op, _) and
    specialMethodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprClass
}

// Retrieves the special method name for comparison or binary operators
private string get_special_method_name() {
  result = any(Cmpop comparisonOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryExpr).getOp().getSpecialMethodName()
}

// Determines if a file is a Jupyter/IPython notebook
predicate is_notebook_file(File notebookFile) {
  exists(Comment comment | comment.getLocation().getFile() = notebookFile |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is within a Jupyter/IPython notebook
predicate is_in_notebook(Expr expr) { 
  is_notebook_file(expr.getScope().(Module).getFile()) 
}

// Retrieves the FunctionValue for unittest.TestCase's assertRaises method
FunctionValue unittest_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is within a `with` block that tests exception raising
predicate is_in_exception_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = unittest_assert_raises_method().getACall().getNode()
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
predicate is_ineffectual_expression(Expr expr) {
  // String literals can serve as comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not binary_operation_has_side_effects(subExpr) and
    not might_cause_side_effects(subExpr)
  ) and
  // Exclude special cases
  not is_in_notebook(expr) and
  not is_in_exception_test(expr) and
  not is_python2_print_stmt(expr)
}

// Select statements with no effect and report the issue
from ExprStmt stmt
where is_ineffectual_expression(stmt.getValue())
select stmt, "This statement has no effect."