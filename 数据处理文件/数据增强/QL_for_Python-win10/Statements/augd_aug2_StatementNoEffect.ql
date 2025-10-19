/**
 * @name Statement has no effect
 * @description Identifies statements that have no effect and can be safely removed
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/ineffectual-statement
 */

import python

// Attribute analysis predicates
/**
 * Determines if an attribute is understood by analyzing its class hierarchy
 * This predicate helps identify attributes that are well-defined within the class system
 */
predicate understood_attribute(Attribute attrAccess, ClassValue sourceType, ClassValue attrType) {
  exists(string attrName | attrAccess.getName() = attrName |
    attrAccess.getObject().pointsTo().getClass() = sourceType and
    sourceType.attr(attrName).getClass() = attrType
  )
}

/**
 * Determines if a descriptor type has side effects when accessed
 * Excludes common built-in descriptor types known to be side-effect free
 */
predicate side_effecting_descriptor_type(ClassValue descriptorType) {
  descriptorType.isDescriptorType() and
  // Exclude specific built-in descriptor types known to be side-effect free
  not descriptorType = ClassValue::functionType() and
  not descriptorType = ClassValue::staticmethod() and
  not descriptorType = ClassValue::classmethod()
}

/**
 * Checks if attribute access might have side effects through descriptor types
 * Attributes using certain descriptor types can trigger side effects when accessed
 */
predicate side_effecting_attribute(Attribute attrAccess) {
  exists(ClassValue descriptorType |
    understood_attribute(attrAccess, _, descriptorType) and
    side_effecting_descriptor_type(descriptorType)
  )
}

/**
 * Identifies attributes that could potentially have side effects
 * This includes both understood attributes with side-effecting descriptors
 * and attributes that are not fully understood through static analysis
 */
predicate maybe_side_effecting_attribute(Attribute attrAccess) {
  not understood_attribute(attrAccess, _, _) and not attrAccess.pointsTo(_)
  or
  side_effecting_attribute(attrAccess)
}

// Binary operation analysis predicates
private string special_method() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

pragma[nomagic]
private predicate binary_operator_special_method(
  BinaryExpr binaryOp, Expr leftOperand, ClassValue leftType, string specialMethodName
) {
  specialMethodName = special_method() and
  leftOperand = binaryOp.getLeft() and
  specialMethodName = binaryOp.getOp().getSpecialMethodName() and
  leftOperand.pointsTo().getClass() = leftType
}

pragma[nomagic]
private predicate comparison_special_method(
  Compare comparison, Expr comparedOperand, ClassValue operandType, string specialMethodName
) {
  exists(Cmpop op |
    comparison.compares(comparedOperand, op, _) and
    specialMethodName = op.getSpecialMethodName()
  ) and
  comparedOperand.pointsTo().getClass() = operandType
}

/**
 * Identifies binary operations that might have side effects
 * Some binary operations can trigger special methods with side effects
 */
predicate side_effecting_binary(Expr operation) {
  exists(Expr operand, ClassValue operandType, string specialMethodName |
    binary_operator_special_method(operation, operand, operandType, specialMethodName)
    or
    comparison_special_method(operation, operand, operandType, specialMethodName)
  |
    specialMethodName = special_method() and
    operandType.hasAttribute(specialMethodName) and
    not exists(ClassValue declaringType |
      declaringType.declaresAttribute(specialMethodName) and
      declaringType = operandType.getASuperType() and
      declaringType.isBuiltin() and
      not declaringType = ClassValue::object()
    )
  )
}

// Context analysis predicates
/**
 * Determines if a file is a Jupyter/IPython notebook
 * Notebooks have different execution semantics where expressions might display output
 */
predicate is_notebook(File sourceFile) {
  exists(Comment comment | comment.getLocation().getFile() = sourceFile |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Identifies expressions within Jupyter/IPython notebooks */
predicate in_notebook(Expr expression) { is_notebook(expression.getScope().(Module).getFile()) }

/**
 * Retrieves the FunctionValue for unittest.TestCase's assertRaises method
 * This method is used in testing contexts to check for expected exceptions
 */
FunctionValue assertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** Checks if an expression is within a test for exception raising */
predicate in_raises_test(Expr expression) {
  exists(With withBlock |
    withBlock.contains(expression) and
    withBlock.getContextExpr() = assertRaises().getACall().getNode()
  )
}

/** Identifies Python 2 print statements using the >> syntax */
predicate python2_print(Expr expression) {
  expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expression.(BinaryExpr).getOp() instanceof RShift
  or
  python2_print(expression.(Tuple).getElt(0))
}

// Core analysis predicate
/**
 * Determines if an expression has no effect
 * This is the main analysis predicate that combines all the checks
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