/**
 * @name Statement has no effect
 * @description Detects statements that have no effect
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

// Helper to determine special method names for operators
private string getOperatorSpecialMethodName() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Identifies special methods for binary operators
pragma[nomagic]
private predicate binaryOperatorSpecialMethod(
  BinaryExpr binaryExpr, Expr leftOperand, ClassValue operandClass, string specialMethod
) {
  specialMethod = getOperatorSpecialMethodName() and
  leftOperand = binaryExpr.getLeft() and
  specialMethod = binaryExpr.getOp().getSpecialMethodName() and
  leftOperand.pointsTo().getClass() = operandClass
}

// Identifies special methods for comparison operations
pragma[nomagic]
private predicate comparisonSpecialMethod(
  Compare compareExpr, Expr comparedOperand, ClassValue operandClass, string specialMethod
) {
  exists(Cmpop op |
    compareExpr.compares(comparedOperand, op, _) and
    specialMethod = op.getSpecialMethodName()
  ) and
  comparedOperand.pointsTo().getClass() = operandClass
}

// Determines if a descriptor type has side effects
predicate descriptorTypeHasSideEffects(ClassValue descriptorType) {
  descriptorType.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // that we want to treat as having no effect
  not descriptorType = ClassValue::functionType() and
  not descriptorType = ClassValue::staticmethod() and
  not descriptorType = ClassValue::classmethod()
}

// Checks if an attribute is understood (resolved to specific classes)
predicate isUnderstoodAttribute(Attribute attrNode, ClassValue ownerClass, ClassValue attrClass) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = ownerClass and
    ownerClass.attr(attrName).getClass() = attrClass
  )
}

// Determines if an attribute access has side effects
predicate attributeAccessHasSideEffects(Attribute attrNode) {
  exists(ClassValue attrClass |
    isUnderstoodAttribute(attrNode, _, attrClass) and
    descriptorTypeHasSideEffects(attrClass)
  )
}

// Checks if an attribute might have side effects
predicate attributeAccessMightHaveSideEffects(Attribute attrNode) {
  not isUnderstoodAttribute(attrNode, _, _) and not attrNode.pointsTo(_)
  or
  attributeAccessHasSideEffects(attrNode)
}

// Determines if a binary operation has side effects
predicate binaryOperationHasSideEffects(Expr binaryExpr) {
  exists(Expr operand, ClassValue operandClass, string specialMethod |
    binaryOperatorSpecialMethod(binaryExpr, operand, operandClass, specialMethod)
    or
    comparisonSpecialMethod(binaryExpr, operand, operandClass, specialMethod)
  |
    specialMethod = getOperatorSpecialMethodName() and
    operandClass.hasAttribute(specialMethod) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(specialMethod) and
      declaring = operandClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Checks if a file is a Jupyter/IPython notebook
predicate isJupyterNotebook(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is in a Jupyter/IPython notebook
predicate isExpressionInNotebook(Expr expr) { 
  isJupyterNotebook(expr.getScope().(Module).getFile()) 
}

// Gets the unittest.TestCase.assertRaises method
FunctionValue getUnittestAssertRaisesMethod() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is in a test for exception raising
predicate isInExceptionTest(Expr expr) {
  exists(With withBlock |
    withBlock.contains(expr) and
    withBlock.getContextExpr() = getUnittestAssertRaisesMethod().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement
predicate isPython2PrintStatement(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  isPython2PrintStatement(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate expressionHasNoEffect(Expr expr) {
  // Strings can be used as docstrings/comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions for side effects
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not binaryOperationHasSideEffects(subExpr) and
    not attributeAccessMightHaveSideEffects(subExpr)
  ) and
  // Exclude special contexts where expressions are expected
  not isExpressionInNotebook(expr) and
  not isInExceptionTest(expr) and
  not isPython2PrintStatement(expr)
}

// Main query to find statements with no effect
from ExprStmt stmt
where expressionHasNoEffect(stmt.getValue())
select stmt, "This statement has no effect."