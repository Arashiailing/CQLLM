/**
 * @name Statement has no effect
 * @description Detects statements that have no effect on program execution
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

// Attribute analysis helpers
/**
 * Determines if an attribute is understood by tracking its class hierarchy
 */
predicate understood_attribute(Attribute attrAccess, ClassValue sourceClass, ClassValue targetClass) {
  exists(string attrName | attrAccess.getName() = attrName |
    attrAccess.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attrName).getClass() = targetClass
  )
}

/**
 * Checks if attribute access has side effects through descriptor types
 */
predicate side_effecting_attribute(Attribute attrAccess) {
  exists(ClassValue descriptorType |
    understood_attribute(attrAccess, _, descriptorType) and
    side_effecting_descriptor_type(descriptorType)
  )
}

/**
 * Identifies attributes that might have side effects
 */
predicate maybe_side_effecting_attribute(Attribute attrAccess) {
  not understood_attribute(attrAccess, _, _) and not attrAccess.pointsTo(_)
  or
  side_effecting_attribute(attrAccess)
}

/**
 * Determines if a descriptor type has side effects
 */
predicate side_effecting_descriptor_type(ClassValue descriptorType) {
  descriptorType.isDescriptorType() and
  // Exclude specific built-in descriptor types known to be side-effect free
  not descriptorType = ClassValue::functionType() and
  not descriptorType = ClassValue::staticmethod() and
  not descriptorType = ClassValue::classmethod()
}

// Binary operation analysis helpers
/**
 * Identifies binary operations with potential side effects
 */
predicate side_effecting_binary(Expr binaryOperation) {
  exists(Expr operandExpr, ClassValue operandType, string methodIdentifier |
    binary_operator_special_method(binaryOperation, operandExpr, operandType, methodIdentifier)
    or
    comparison_special_method(binaryOperation, operandExpr, operandType, methodIdentifier)
  |
    methodIdentifier = special_method() and
    operandType.hasAttribute(methodIdentifier) and
    not exists(ClassValue declaringClass |
      declaringClass.declaresAttribute(methodIdentifier) and
      declaringClass = operandType.getASuperType() and
      declaringClass.isBuiltin() and
      not declaringClass = ClassValue::object()
    )
  )
}

pragma[nomagic]
private predicate binary_operator_special_method(
  BinaryExpr binaryOperation, Expr leftOperand, ClassValue leftClass, string methodIdentifier
) {
  methodIdentifier = special_method() and
  leftOperand = binaryOperation.getLeft() and
  methodIdentifier = binaryOperation.getOp().getSpecialMethodName() and
  leftOperand.pointsTo().getClass() = leftClass
}

pragma[nomagic]
private predicate comparison_special_method(
  Compare compareExpr, Expr comparedOperand, ClassValue operandType, string methodIdentifier
) {
  exists(Cmpop op |
    compareExpr.compares(comparedOperand, op, _) and
    methodIdentifier = op.getSpecialMethodName()
  ) and
  comparedOperand.pointsTo().getClass() = operandType
}

private string special_method() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Notebook analysis helpers
/**
 * Checks if a file is a Jupyter/IPython notebook
 */
predicate is_notebook(File file) {
  exists(Comment fileComment | fileComment.getLocation().getFile() = file |
    fileComment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Identifies expressions within Jupyter/IPython notebooks */
predicate in_notebook(Expr expression) { is_notebook(expression.getScope().(Module).getFile()) }

// Testing context helpers
/**
 * Gets the FunctionValue for unittest.TestCase's assertRaises method
 */
FunctionValue assertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** Checks if an expression is within a test for exception raising */
predicate in_raises_test(Expr expression) {
  exists(With withStmt |
    withStmt.contains(expression) and
    withStmt.getContextExpr() = assertRaises().getACall().getNode()
  )
}

// Python 2 compatibility helpers
/** Identifies Python 2 print statements (>> syntax) */
predicate python2_print(Expr expression) {
  expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expression.(BinaryExpr).getOp() instanceof RShift
  or
  python2_print(expression.(Tuple).getElt(0))
}

// Core analysis predicate
/**
 * Determines if an expression has no effect
 */
predicate no_effect(Expr expression) {
  // Exclude string literals (used as docstrings/comments)
  not expression instanceof StringLiteral and
  // Exclude expressions with known side effects
  not expression.hasSideEffects() and
  // Check all sub-expressions for potential side effects
  forall(Expr subExpr | subExpr = expression.getASubExpression*() |
    not side_effecting_binary(subExpr) and
    not maybe_side_effecting_attribute(subExpr)
  ) and
  // Exclude special contexts where expressions might have semantic meaning
  not in_notebook(expression) and
  not in_raises_test(expression) and
  not python2_print(expression)
}

// Main query
from ExprStmt statement
where no_effect(statement.getValue())
select statement, "This statement has no effect."