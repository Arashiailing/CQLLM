/**
 * @name Statement has no effect
 * @description A statement has no effect
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

// Attribute analysis predicates
/**
 * Determines if an attribute is understood by tracking its class hierarchy
 */
predicate understood_attribute(Attribute attrRef, ClassValue originClass, ClassValue attrClass) {
  exists(string attrName | attrRef.getName() = attrName |
    attrRef.getObject().pointsTo().getClass() = originClass and
    originClass.attr(attrName).getClass() = attrClass
  )
}

/**
 * Checks if attribute access has side effects through descriptor types
 */
predicate side_effecting_attribute(Attribute attrRef) {
  exists(ClassValue descriptorClass |
    understood_attribute(attrRef, _, descriptorClass) and
    side_effecting_descriptor_type(descriptorClass)
  )
}

/**
 * Identifies attributes that might have side effects
 */
predicate maybe_side_effecting_attribute(Attribute attrRef) {
  not understood_attribute(attrRef, _, _) and not attrRef.pointsTo(_)
  or
  side_effecting_attribute(attrRef)
}

/**
 * Determines if a descriptor type has side effects
 */
predicate side_effecting_descriptor_type(ClassValue descriptor) {
  descriptor.isDescriptorType() and
  // Exclude specific built-in descriptor types known to be side-effect free
  not descriptor = ClassValue::functionType() and
  not descriptor = ClassValue::staticmethod() and
  not descriptor = ClassValue::classmethod()
}

// Binary operation analysis predicates
/**
 * Identifies binary operations with potential side effects
 */
predicate side_effecting_binary(Expr binaryExpr) {
  exists(Expr operand, ClassValue operandClass, string methodName |
    binary_operator_special_method(binaryExpr, operand, operandClass, methodName)
    or
    comparison_special_method(binaryExpr, operand, operandClass, methodName)
  |
    methodName = special_method() and
    operandClass.hasAttribute(methodName) and
    not exists(ClassValue declaringClass |
      declaringClass.declaresAttribute(methodName) and
      declaringClass = operandClass.getASuperType() and
      declaringClass.isBuiltin() and
      not declaringClass = ClassValue::object()
    )
  )
}

pragma[nomagic]
private predicate binary_operator_special_method(
  BinaryExpr binaryExpr, Expr leftOperand, ClassValue leftClass, string methodName
) {
  methodName = special_method() and
  leftOperand = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  leftOperand.pointsTo().getClass() = leftClass
}

pragma[nomagic]
private predicate comparison_special_method(
  Compare compareExpr, Expr comparedOperand, ClassValue operandClass, string methodName
) {
  exists(Cmpop op |
    compareExpr.compares(comparedOperand, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  comparedOperand.pointsTo().getClass() = operandClass
}

private string special_method() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Notebook analysis predicates
/**
 * Checks if a file is a Jupyter/IPython notebook
 */
predicate is_notebook(File sourceFile) {
  exists(Comment comment | comment.getLocation().getFile() = sourceFile |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Identifies expressions within Jupyter/IPython notebooks */
predicate in_notebook(Expr expr) { is_notebook(expr.getScope().(Module).getFile()) }

// Testing context predicates
/**
 * Gets the FunctionValue for unittest.TestCase's assertRaises method
 */
FunctionValue assertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** Checks if an expression is within a test for exception raising */
predicate in_raises_test(Expr expr) {
  exists(With withBlock |
    withBlock.contains(expr) and
    withBlock.getContextExpr() = assertRaises().getACall().getNode()
  )
}

// Python 2 compatibility predicates
/** Identifies Python 2 print statements (>> syntax) */
predicate python2_print(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  python2_print(expr.(Tuple).getElt(0))
}

// Core analysis predicate
/**
 * Determines if an expression has no effect
 */
predicate no_effect(Expr expr) {
  // Exclude string literals (used as docstrings/comments)
  not expr instanceof StringLiteral and
  // Exclude expressions with known side effects
  not expr.hasSideEffects() and
  // Check all sub-expressions for potential side effects
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not side_effecting_binary(subExpr) and
    not maybe_side_effecting_attribute(subExpr)
  ) and
  // Exclude special contexts where expressions might have semantic meaning
  not in_notebook(expr) and
  not in_raises_test(expr) and
  not python2_print(expr)
}

// Main query
from ExprStmt stmt
where no_effect(stmt.getValue())
select stmt, "This statement has no effect."