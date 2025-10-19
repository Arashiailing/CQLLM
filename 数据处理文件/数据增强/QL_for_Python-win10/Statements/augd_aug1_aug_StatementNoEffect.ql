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
predicate is_attribute_understood(Attribute attribute, ClassValue sourceClass, ClassValue attributeClass) {
  exists(string attributeName | attribute.getName() = attributeName |
    attribute.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attributeName).getClass() = attributeClass
  )
}

// Checks if a descriptor type has side effects when accessed
predicate is_descriptor_type_side_effecting(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // Technically all descriptor accesses have side effects, but some represent missing calls
  // which we want to treat as having no effect
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

/* Conservatively determines if attribute access might have side effects */
predicate has_side_effecting_attr(Attribute attribute) {
  exists(ClassValue attributeClass |
    is_attribute_understood(attribute, _, attributeClass) and
    is_descriptor_type_side_effecting(attributeClass)
  )
}

// Identifies attributes that might potentially have side effects
predicate might_have_side_effect_attr(Attribute attribute) {
  // Case 1: Attribute is not understood or doesn't point to a concrete value
  (not is_attribute_understood(attribute, _, _) and not attribute.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  has_side_effecting_attr(attribute)
}

/**
 * Binary operators with side effects are rare, so we assume they have no side effects
 * unless we know otherwise
 */
predicate is_binary_side_effecting(Expr binaryExpression) {
  exists(Expr subExpression, ClassValue expressionClass, string methodName |
    // Handle binary operator special methods
    is_special_binary_operator(binaryExpression, subExpression, expressionClass, methodName)
    or
    // Handle comparison operator special methods
    is_special_comparison_operator(binaryExpression, subExpression, expressionClass, methodName)
  |
    methodName = get_special_method_name() and
    expressionClass.hasAttribute(methodName) and
    // Exclude inherited methods from built-in types (except object)
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = expressionClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

pragma[nomagic]
private predicate is_special_binary_operator(
  BinaryExpr binaryExpression, Expr subExpression, ClassValue expressionClass, string methodName
) {
  methodName = get_special_method_name() and
  subExpression = binaryExpression.getLeft() and
  methodName = binaryExpression.getOp().getSpecialMethodName() and
  subExpression.pointsTo().getClass() = expressionClass
}

pragma[nomagic]
private predicate is_special_comparison_operator(Compare binaryExpression, Expr subExpression, ClassValue expressionClass, string methodName) {
  exists(Cmpop op |
    binaryExpression.compares(subExpression, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpression.pointsTo().getClass() = expressionClass
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
predicate expr_in_notebook(Expr expression) { 
  is_notebook_file(expression.getScope().(Module).getFile()) 
}

// Retrieves the FunctionValue object for unittest.TestCase's assertRaises method
FunctionValue get_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** True if expression `expression` is within a `with` block that tests exception raising */
predicate expr_in_raises_test(Expr expression) {
  exists(With withStatement |
    withStatement.contains(expression) and
    withStatement.getContextExpr() = get_assert_raises_method().getACall().getNode()
  )
}

/** True if expression has the form of Python 2 `print >> out, ...` statement */
predicate is_python2_print_stmt(Expr expression) {
  // Handle print >> syntax
  (expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expression.(BinaryExpr).getOp() instanceof RShift)
  or
  // Recursively handle first element in tuple
  is_python2_print_stmt(expression.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate expression_has_no_effect(Expr expression) {
  // String literals can serve as comments
  not expression instanceof StringLiteral and
  not expression.hasSideEffects() and
  // Check all sub-expressions
  forall(Expr subExpression | subExpression = expression.getASubExpression*() |
    not is_binary_side_effecting(subExpression) and
    not might_have_side_effect_attr(subExpression)
  ) and
  // Exclude special cases
  not expr_in_notebook(expression) and
  not expr_in_raises_test(expression) and
  not is_python2_print_stmt(expression)
}

// Select statements with no effect and report the issue
from ExprStmt ineffectualStatement
where expression_has_no_effect(ineffectualStatement.getValue())
select ineffectualStatement, "This statement has no effect."