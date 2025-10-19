/**
 * @name Statement has no effect
 * @description Identifies statements that have no effect on the program's behavior
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

// Determines if an attribute access is understood by the analysis
predicate is_attribute_understood(Attribute attributeAccess, ClassValue sourceClass, ClassValue attributeClass) {
  exists(string attributeName | attributeAccess.getName() = attributeName |
    attributeAccess.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attributeName).getClass() = attributeClass
  )
}

/* Conservatively estimates if attribute access might have side effects */
predicate has_side_effecting_attribute(Attribute attributeAccess) {
  exists(ClassValue attributeClass |
    is_attribute_understood(attributeAccess, _, attributeClass) and
    is_descriptor_type_side_effecting(attributeClass)
  )
}

// Determines if an attribute access might potentially have side effects
predicate might_have_side_effect_attribute(Attribute attributeAccess) {
  not is_attribute_understood(attributeAccess, _, _) and not attributeAccess.pointsTo(_)
  or
  has_side_effecting_attribute(attributeAccess)
}

// Checks if a descriptor type is known to have side effects
predicate is_descriptor_type_side_effecting(ClassValue descriptor) {
  descriptor.isDescriptorType() and
  // Technically all descriptor accesses have side effects, but some represent missing calls
  // which we want to treat as having no effect.
  not descriptor = ClassValue::functionType() and
  not descriptor = ClassValue::staticmethod() and
  not descriptor = ClassValue::classmethod()
}

/**
 * Binary operators with side effects are rare, so we assume they have no side effects
 * unless we know otherwise.
 */
predicate has_side_effecting_binary(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue exprClass, string methodName |
    is_binary_operator_special_method(binaryExpr, subExpr, exprClass, methodName)
    or
    is_comparison_special_method(binaryExpr, subExpr, exprClass, methodName)
  |
    methodName = get_special_method_name() and
    exprClass.hasAttribute(methodName) and
    not exists(ClassValue declaringClass |
      declaringClass.declaresAttribute(methodName) and
      declaringClass = exprClass.getASuperType() and
      declaringClass.isBuiltin() and
      not declaringClass = ClassValue::object()
    )
  )
}

pragma[nomagic]
private predicate is_binary_operator_special_method(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprClass
}

pragma[nomagic]
private predicate is_comparison_special_method(Compare comparisonExpr, Expr subExpr, ClassValue exprClass, string methodName) {
  exists(Cmpop op |
    comparisonExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprClass
}

private string get_special_method_name() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Determines if a file is a Jupyter/IPython notebook
predicate is_jupyter_notebook(File sourceFile) {
  exists(Comment comment | comment.getLocation().getFile() = sourceFile |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Expressions (statements) within Jupyter/IPython notebooks */
predicate is_in_notebook(Expr expr) { is_jupyter_notebook(expr.getScope().(Module).getFile()) }

// Retrieves the FunctionValue object for the assertRaises method in unittest.TestCase
FunctionValue get_unittest_assert_raises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** Holds if expression `expr` is within a `with` block that tests for exception raising. */
predicate is_in_exception_test(Expr expr) {
  exists(With withBlock |
    withBlock.contains(expr) and
    withBlock.getContextExpr() = get_unittest_assert_raises().getACall().getNode()
  )
}

/** Holds if expression `expr` has the form of a Python 2 `print >> out, ...` statement */
predicate is_python2_print(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  is_python2_print(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate has_no_effect(Expr expr) {
  // Strings can be used as comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not has_side_effecting_binary(subExpr) and
    not might_have_side_effect_attribute(subExpr)
  ) and
  not is_in_notebook(expr) and
  not is_in_exception_test(expr) and
  not is_python2_print(expr)
}

// Selects expression statements that have no effect and report them as issues
from ExprStmt statement
where has_no_effect(statement.getValue())
select statement, "This statement has no effect."