/**
 * @name Statement has no effect
 * @description This rule identifies statements that have no effect during program execution.
 *              Such statements are often the result of dead code or incomplete refactoring.
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

/**
 * Determines if an attribute is well-understood in terms of its source and target classes.
 * This means we can trace the attribute's source class and the class of the attribute itself.
 */
predicate is_attribute_understood(Attribute attribute, ClassValue sourceClass, ClassValue attributeClass) {
  exists(string attributeName | attribute.getName() = attributeName |
    attribute.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attributeName).getClass() = attributeClass
  )
}

/**
 * Conservatively determines if an attribute access might have side effects.
 * This is true if the attribute is understood and its descriptor type is known to have side effects.
 */
predicate has_side_effecting_attr(Attribute attribute) {
  exists(ClassValue attributeClass |
    is_attribute_understood(attribute, _, attributeClass) and
    is_descriptor_type_side_effecting(attributeClass)
  )
}

/**
 * Identifies attributes that might potentially have side effects.
 * This includes two cases:
 *   1. The attribute is not understood (i.e., we cannot trace its source and target classes) 
 *      and it doesn't point to a concrete value.
 *   2. The attribute is already identified as having side effects.
 */
predicate might_have_side_effect_attr(Attribute attribute) {
  (not is_attribute_understood(attribute, _, _) and not attribute.pointsTo(_))
  or
  has_side_effecting_attr(attribute)
}

/**
 * Checks if a descriptor type has side effects when accessed.
 * Although all descriptor accesses technically have side effects, we exclude some types
 * (function, staticmethod, classmethod) because they often represent missing calls and we want
 * to treat them as having no effect.
 */
predicate is_descriptor_type_side_effecting(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

/**
 * Determines if a binary expression might have side effects.
 * Binary operators with side effects are rare, so we assume they have no side effects
 * unless we know otherwise. This predicate checks for the presence of special methods
 * that could cause side effects, excluding those inherited from built-in types (except object).
 */
predicate is_binary_side_effecting(Expr binaryExpression) {
  exists(Expr subExpression, ClassValue expressionClass, string methodName |
    is_special_binary_operator(binaryExpression, subExpression, expressionClass, methodName)
    or
    is_special_comparison_operator(binaryExpression, subExpression, expressionClass, methodName)
  |
    methodName = get_special_method_name() and
    expressionClass.hasAttribute(methodName) and
    not exists(ClassValue declaringClass |
      declaringClass.declaresAttribute(methodName) and
      declaringClass = expressionClass.getASuperType() and
      declaringClass.isBuiltin() and
      not declaringClass = ClassValue::object()
    )
  )
}

/**
 * Helper predicate to check if a binary expression uses a special binary operator method.
 * This matches when the method name corresponds to the operator and the left operand's class
 * is the expression class.
 */
pragma[nomagic]
private predicate is_special_binary_operator(
  BinaryExpr binaryExpression, Expr subExpression, ClassValue expressionClass, string methodName
) {
  methodName = get_special_method_name() and
  subExpression = binaryExpression.getLeft() and
  methodName = binaryExpression.getOp().getSpecialMethodName() and
  subExpression.pointsTo().getClass() = expressionClass
}

/**
 * Helper predicate to check if a comparison expression uses a special comparison operator method.
 * This matches when the method name corresponds to the comparison operator and the sub-expression's class
 * is the expression class.
 */
pragma[nomagic]
private predicate is_special_comparison_operator(Compare comparisonExpr, Expr subExpression, ClassValue expressionClass, string methodName) {
  exists(Cmpop operator |
    comparisonExpr.compares(subExpression, operator, _) and
    methodName = operator.getSpecialMethodName()
  ) and
  subExpression.pointsTo().getClass() = expressionClass
}

/**
 * Gets the special method name for any comparison or binary operator.
 * This is used to identify the method that would be called for a given operator.
 */
private string get_special_method_name() {
  result = any(Cmpop comparisonOperator).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryExpression).getOp().getSpecialMethodName()
}

/**
 * Determines if a file is a Jupyter/IPython notebook by checking for the presence of
 * a comment containing the nbformat tag.
 */
predicate is_notebook_file(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/**
 * Determines if an expression is within a Jupyter/IPython notebook.
 */
predicate expr_in_notebook(Expr expression) { 
  is_notebook_file(expression.getScope().(Module).getFile()) 
}

/**
 * Retrieves the FunctionValue object for unittest.TestCase's assertRaises method.
 * This is used to identify when an expression is within a context manager that tests exception raising.
 */
FunctionValue get_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/**
 * Determines if an expression is within a `with` block that tests exception raising.
 * This is true if the expression is inside a `with` statement whose context expression is a call
 * to `unittest.TestCase.assertRaises`.
 */
predicate expr_in_raises_test(Expr expression) {
  exists(With withStatement |
    withStatement.contains(expression) and
    withStatement.getContextExpr() = get_assert_raises_method().getACall().getNode()
  )
}

/**
 * Determines if an expression has the form of a Python 2 `print >> out, ...` statement.
 * This includes the direct case of a binary expression with a left operand "print" and a right shift operator,
 * and the recursive case where the expression is a tuple and the first element is such a print statement.
 */
predicate is_python2_print_stmt(Expr expression) {
  (expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expression.(BinaryExpr).getOp() instanceof RShift)
  or
  is_python2_print_stmt(expression.(Tuple).getElt(0))
}

/**
 * Determines if an expression has no effect during program execution.
 * This is true if:
 *   - The expression is not a string literal (which can serve as documentation).
 *   - The expression does not have side effects.
 *   - None of its sub-expressions are binary expressions with side effects or attributes that might have side effects.
 *   - The expression is not in a notebook, not in a raises test, and not a Python 2 print statement.
 */
predicate expression_has_no_effect(Expr expression) {
  not expression instanceof StringLiteral and
  not expression.hasSideEffects() and
  forall(Expr subExpression | subExpression = expression.getASubExpression*() |
    not is_binary_side_effecting(subExpression) and
    not might_have_side_effect_attr(subExpression)
  ) and
  not expr_in_notebook(expression) and
  not expr_in_raises_test(expression) and
  not is_python2_print_stmt(expression)
}

/**
 * Selects expression statements that have no effect and reports the issue.
 */
from ExprStmt statement
where expression_has_no_effect(statement.getValue())
select statement, "This statement has no effect."