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
predicate is_properly_defined_attribute(Attribute attribute, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attributeName | attribute.getName() = attributeName |
    attribute.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attributeName).getClass() = attrCls
  )
}

/* Determines if an attribute access could potentially cause side effects */
predicate causes_side_effects(Attribute attribute) {
  exists(ClassValue attrCls |
    is_properly_defined_attribute(attribute, _, attrCls) and
    descriptor_has_side_effects(attrCls)
  )
}

// Identifies attributes that might have side effects during execution
predicate might_cause_side_effects(Attribute attribute) {
  // Case 1: Attribute is not properly defined or doesn't reference a concrete value
  (not is_properly_defined_attribute(attribute, _, _) and not attribute.pointsTo(_))
  or
  // Case 2: Attribute is already identified as causing side effects
  causes_side_effects(attribute)
}

// Checks if accessing a descriptor type results in side effects
predicate descriptor_has_side_effects(ClassValue descriptorCls) {
  descriptorCls.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // which we want to treat as having no effect
  not descriptorCls = ClassValue::functionType() and
  not descriptorCls = ClassValue::staticmethod() and
  not descriptorCls = ClassValue::classmethod()
}

/**
 * Binary operators typically don't have side effects, so we assume they are safe
 * unless proven otherwise
 */
predicate binary_operation_has_side_effects(Expr binaryOperation) {
  exists(Expr subExpression, ClassValue expressionClass, string specialMethodName |
    // Handle binary operator special methods
    uses_special_binary_operator(binaryOperation, subExpression, expressionClass, specialMethodName)
    or
    // Handle comparison operator special methods
    uses_special_comparison_operator(binaryOperation, subExpression, expressionClass, specialMethodName)
  |
    specialMethodName = get_special_method_name() and
    expressionClass.hasAttribute(specialMethodName) and
    // Exclude inherited methods from built-in types (except object)
    not exists(ClassValue declaringClass |
      declaringClass.declaresAttribute(specialMethodName) and
      declaringClass = expressionClass.getASuperType() and
      declaringClass.isBuiltin() and
      not declaringClass = ClassValue::object()
    )
  )
}

// Identifies binary expressions that use special operator methods
pragma[nomagic]
private predicate uses_special_binary_operator(
  BinaryExpr binaryOperation, Expr subExpression, ClassValue expressionClass, string specialMethodName
) {
  specialMethodName = get_special_method_name() and
  subExpression = binaryOperation.getLeft() and
  specialMethodName = binaryOperation.getOp().getSpecialMethodName() and
  subExpression.pointsTo().getClass() = expressionClass
}

// Identifies comparison expressions that use special operator methods
pragma[nomagic]
private predicate uses_special_comparison_operator(Compare binaryOperation, Expr subExpression, ClassValue expressionClass, string specialMethodName) {
  exists(Cmpop op |
    binaryOperation.compares(subExpression, op, _) and
    specialMethodName = op.getSpecialMethodName()
  ) and
  subExpression.pointsTo().getClass() = expressionClass
}

// Retrieves the special method name for comparison or binary operators
private string get_special_method_name() {
  result = any(Cmpop comparisonOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryOperation).getOp().getSpecialMethodName()
}

// Determines if a file is a Jupyter/IPython notebook
predicate is_notebook_file(File notebook) {
  exists(Comment comment | comment.getLocation().getFile() = notebook |
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
  forall(Expr subExpression | subExpression = expr.getASubExpression*() |
    not binary_operation_has_side_effects(subExpression) and
    not might_cause_side_effects(subExpression)
  ) and
  // Exclude special cases
  not is_in_notebook(expr) and
  not is_in_exception_test(expr) and
  not is_python2_print_stmt(expr)
}

// Select statements with no effect and report the issue
from ExprStmt statement
where is_ineffectual_expression(statement.getValue())
select statement, "This statement has no effect."