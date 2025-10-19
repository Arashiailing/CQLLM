/**
 * @name Redundant assignment
 * @description Identifies self-assignments where a variable is assigned to itself, indicating potential coding errors
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

// Extracts assignment components: statement, left-hand side expression, and right-hand side expression
predicate getAssignmentComponents(AssignStmt assignmentStmt, Expr lhsExpr, Expr rhsExpr) {
  assignmentStmt.getATarget() = lhsExpr and assignmentStmt.getValue() = rhsExpr
}

// Determines expression correspondence including nested attribute objects
predicate expressionsCorrespond(Expr lhsExpr, Expr rhsExpr) {
  getAssignmentComponents(_, lhsExpr, rhsExpr)
  or
  exists(Attribute lhsAttr, Attribute rhsAttr |
    expressionsCorrespond(lhsAttr, rhsAttr) and
    lhsExpr = lhsAttr.getObject() and
    rhsExpr = rhsAttr.getObject()
  )
}

// Checks value equivalence between expressions (either names or attributes)
predicate valuesAreEquivalent(Expr lhsExpr, Expr rhsExpr) {
  namesAreIdentical(lhsExpr, rhsExpr) or attributesAreIdentical(lhsExpr, rhsExpr)
}

// Verifies identical names under specific conditions
predicate namesAreIdentical(Name firstName, Name secondName) {
  expressionsCorrespond(firstName, secondName) and
  firstName.getVariable() = secondName.getVariable() and
  not exists(Value builtinValue | 
    builtinValue = Value::named(firstName.getId()) and builtinValue.isBuiltin() 
  ) and
  not exists(SsaVariable ssaVariable | 
    ssaVariable.getAUse().getNode() = secondName and ssaVariable.maybeUndefined()
  )
}

// Determines if an attribute represents property access
predicate isPropertyAccess(Attribute attr) {
  exists(ClassValue classType |
    attr.getObject().pointsTo().getClass() = classType and
    classType.lookup(attr.getName()) instanceof PropertyValue
  )
}

// Verifies identical attributes under specific conditions
predicate attributesAreIdentical(Attribute firstAttr, Attribute secondAttr) {
  expressionsCorrespond(firstAttr, secondAttr) and
  firstAttr.getName() = secondAttr.getName() and
  valuesAreEquivalent(firstAttr.getObject(), secondAttr.getObject()) and
  exists(firstAttr.getObject().pointsTo().getClass()) and
  not isPropertyAccess(firstAttr)
}

// Prevents magic comments from interfering with analysis
pragma[nomagic]
Comment findPyflakesMagicComment() { 
  result.getText().toLowerCase().matches("%pyflakes%") 
}

// Checks if an assignment statement has a Pyflakes comment
predicate containsPyflakesComment(AssignStmt assignmentStmt) {
  exists(Location location, File file, int lineNumber |
    assignmentStmt.getLocation() = location and
    location.hasLocationInfo(file.getAbsolutePath(), lineNumber, _, _, _) and
    findPyflakesMagicComment().getLocation().hasLocationInfo(file.getAbsolutePath(), lineNumber, _, _, _)
  )
}

// Detects side effects in left-hand side attribute expressions
predicate hasLhsSideEffects(Attribute lhsAttr) {
  exists(ClassValue classType, ClassValue superClassType |
    lhsAttr.getObject().pointsTo().getClass() = classType and
    superClassType = classType.getASuperType() and
    not superClassType.isBuiltin() and
    superClassType.declaresAttribute("__setattr__")
  )
}

// Main query: Finds self-assignments without Pyflakes comments or side effects
from AssignStmt assignmentStmt, Expr lhsExpr, Expr rhsExpr
where
  getAssignmentComponents(assignmentStmt, lhsExpr, rhsExpr) and
  valuesAreEquivalent(lhsExpr, rhsExpr) and
  not containsPyflakesComment(assignmentStmt) and
  not hasLhsSideEffects(lhsExpr)
select assignmentStmt, "This assignment assigns a variable to itself."