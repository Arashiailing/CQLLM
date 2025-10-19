/**
 * @name Redundant assignment
 * @description Detects self-assignments where a variable is assigned to itself, indicating potential coding errors.
 * @kind problem
 * @tags reliability
 *       useless-code
 *       external/cwe/cwe-563
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-assignment
 */

import python

// Identifies assignment statements with their left-hand and right-hand expressions
predicate assignmentDetails(AssignStmt assignStmt, Expr leftExp, Expr rightExp) {
  assignStmt.getATarget() = leftExp and assignStmt.getValue() = rightExp
}

// Recursively determines expression correspondence including attribute objects
predicate expressionCorrespondence(Expr leftExp, Expr rightExp) {
  assignmentDetails(_, leftExp, rightExp)
  or
  exists(Attribute leftAttr, Attribute rightAttr |
    expressionCorrespondence(leftAttr, rightAttr) and
    leftExp = leftAttr.getObject() and
    rightExp = rightAttr.getObject()
  )
}

// Checks if two expressions have equivalent values (identical names or attributes)
predicate equivalentValues(Expr leftExp, Expr rightExp) {
  identicalNames(leftExp, rightExp) or identicalAttributes(leftExp, rightExp)
}

// Determines if two names are identical under specific conditions
predicate identicalNames(Name firstVar, Name secondVar) {
  expressionCorrespondence(firstVar, secondVar) and
  firstVar.getVariable() = secondVar.getVariable() and
  not exists(Value builtinVal | 
    builtinVal = Value::named(firstVar.getId()) and builtinVal.isBuiltin() 
  ) and
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse().getNode() = secondVar and ssaVar.maybeUndefined()
  )
}

// Checks if an attribute represents a property access
predicate propertyAccessCheck(Attribute attribute) {
  exists(ClassValue clsType |
    attribute.getObject().pointsTo().getClass() = clsType and
    clsType.lookup(attribute.getName()) instanceof PropertyValue
  )
}

// Determines if two attributes are identical under specific conditions
predicate identicalAttributes(Attribute firstAttribute, Attribute secondAttribute) {
  expressionCorrespondence(firstAttribute, secondAttribute) and
  firstAttribute.getName() = secondAttribute.getName() and
  equivalentValues(firstAttribute.getObject(), secondAttribute.getObject()) and
  exists(firstAttribute.getObject().pointsTo().getClass()) and
  not propertyAccessCheck(firstAttribute)
}

// Prevents magic comments from interfering with analysis
pragma[nomagic]
Comment pyflakesMagicComment() { 
  result.getText().toLowerCase().matches("%pyflakes%") 
}

// Checks if an assignment statement is marked with a Pyflakes comment
predicate hasPyflakesComment(AssignStmt assignStmt) {
  exists(Location loc, File fileObj, int lineNum |
    assignStmt.getLocation() = loc and
    loc.hasLocationInfo(fileObj.getAbsolutePath(), lineNum, _, _, _) and
    pyflakesMagicComment().getLocation().hasLocationInfo(fileObj.getAbsolutePath(), lineNum, _, _, _)
  )
}

// Detects side effects in left-hand side attribute expressions
predicate lhsSideEffects(Attribute lhsAttribute) {
  exists(ClassValue clsType, ClassValue superClsType |
    lhsAttribute.getObject().pointsTo().getClass() = clsType and
    superClsType = clsType.getASuperType() and
    not superClsType.isBuiltin() and
    superClsType.declaresAttribute("__setattr__")
  )
}

// Main query: Finds self-assignments without Pyflakes comments or side effects
from AssignStmt assignStmt, Expr leftExp, Expr rightExp
where
  assignmentDetails(assignStmt, leftExp, rightExp) and
  equivalentValues(leftExp, rightExp) and
  not hasPyflakesComment(assignStmt) and
  not lhsSideEffects(leftExp)
select assignStmt, "This assignment assigns a variable to itself."