/**
 * @name Statement has no effect
 * @description Identifies statements that do not produce any effect
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

// Helper to retrieve special method names for operators
private string getSpecialMethodNameForOperator() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Identifies special methods for both binary operators and comparison operations
pragma[nomagic]
private predicate isOperatorSpecialMethod(
  Expr operatorExpr, Expr operand, ClassValue operandClass, string specialMethod
) {
  // Handle binary expressions
  exists(BinaryExpr binaryExpr |
    binaryExpr = operatorExpr and
    specialMethod = binaryExpr.getOp().getSpecialMethodName() and
    operand = binaryExpr.getLeft() and
    operand.pointsTo().getClass() = operandClass and
    specialMethod = getSpecialMethodNameForOperator()
  )
  or
  // Handle comparison expressions
  exists(Compare compareExpr, Cmpop op |
    compareExpr = operatorExpr and
    compareExpr.compares(operand, op, _) and
    specialMethod = op.getSpecialMethodName() and
    operand.pointsTo().getClass() = operandClass and
    specialMethod = getSpecialMethodNameForOperator()
  )
}

// Determines if a descriptor type produces side effects
predicate doesDescriptorTypeHaveSideEffects(ClassValue descriptorType) {
  descriptorType.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // that we want to treat as having no effect
  not descriptorType = ClassValue::functionType() and
  not descriptorType = ClassValue::staticmethod() and
  not descriptorType = ClassValue::classmethod()
}

// Checks if an attribute can be resolved to specific classes
predicate isResolvableAttribute(Attribute attrNode, ClassValue ownerClass, ClassValue attrClass) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = ownerClass and
    ownerClass.attr(attrName).getClass() = attrClass
  )
}

// Determines if an attribute access produces side effects
predicate doesAttributeAccessHaveSideEffects(Attribute attrNode) {
  exists(ClassValue attrClass |
    isResolvableAttribute(attrNode, _, attrClass) and
    doesDescriptorTypeHaveSideEffects(attrClass)
  )
}

// Checks if an attribute might produce side effects
predicate mightAttributeAccessHaveSideEffects(Attribute attrNode) {
  not isResolvableAttribute(attrNode, _, _) and not attrNode.pointsTo(_)
  or
  doesAttributeAccessHaveSideEffects(attrNode)
}

// Determines if a binary operation produces side effects
predicate doesBinaryOperationHaveSideEffects(Expr binaryExpr) {
  exists(Expr operand, ClassValue operandClass, string specialMethod |
    isOperatorSpecialMethod(binaryExpr, operand, operandClass, specialMethod) and
    specialMethod = getSpecialMethodNameForOperator() and
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
predicate isFileJupyterNotebook(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is located within a Jupyter/IPython notebook
predicate isExprInJupyterNotebook(Expr expr) { 
  isFileJupyterNotebook(expr.getScope().(Module).getFile()) 
}

// Retrieves the unittest.TestCase.assertRaises method
FunctionValue findUnittestAssertRaisesMethod() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is part of a test for exception raising
predicate isExprInsideExceptionTest(Expr expr) {
  exists(With withBlock |
    withBlock.contains(expr) and
    withBlock.getContextExpr() = findUnittestAssertRaisesMethod().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement
predicate isExprPython2PrintStatement(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  isExprPython2PrintStatement(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate doesExpressionHaveNoEffect(Expr expr) {
  // Strings can be used as docstrings/comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions for side effects
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not doesBinaryOperationHaveSideEffects(subExpr) and
    not mightAttributeAccessHaveSideEffects(subExpr)
  ) and
  // Exclude special contexts where expressions are expected
  not isExprInJupyterNotebook(expr) and
  not isExprInsideExceptionTest(expr) and
  not isExprPython2PrintStatement(expr)
}

// Main query to find statements with no effect
from ExprStmt stmt
where doesExpressionHaveNoEffect(stmt.getValue())
select stmt, "This statement has no effect."