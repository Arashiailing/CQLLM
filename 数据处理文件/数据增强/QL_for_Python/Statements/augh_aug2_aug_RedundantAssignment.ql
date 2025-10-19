/**
 * @name Redundant self-assignment
 * @description Detects assignments where a variable is assigned to itself,
 *              which typically indicates a coding error or useless code.
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

// Extracts the components (left-hand side and right-hand side) from an assignment statement
predicate extractAssignmentComponents(AssignStmt assignmentStmt, Expr leftSide, Expr rightSide) {
  assignmentStmt.getATarget() = leftSide and assignmentStmt.getValue() = rightSide
}

// Recursively verifies if two expressions are equivalent, including nested attribute access
predicate checkExpressionEquivalence(Expr firstExpr, Expr secondExpr) {
  extractAssignmentComponents(_, firstExpr, secondExpr)
  or
  exists(Attribute firstAttr, Attribute secondAttr |
    checkExpressionEquivalence(firstAttr, secondAttr) and
    firstExpr = firstAttr.getObject() and
    secondExpr = secondAttr.getObject()
  )
}

// Determines if two expressions evaluate to the same value (either identical names or attributes)
predicate evaluateExpressionEquality(Expr firstExpr, Expr secondExpr) {
  areNamesIdentical(firstExpr, secondExpr) or areAttributesIdentical(firstExpr, secondExpr)
}

// Checks if a name might be undefined in an outer scope
predicate checkOuterScopeUndefinedStatus(Name name) {
  exists(SsaVariable var | var.getAUse().getNode() = name | var.maybeUndefined())
}

/*
 * Protection against false positives in projects offering Python 2/3 compatibility,
 * as they often contain assignments like:
 *
 * if PY2:
 *     bytes = str
 * else:
 *     bytes = bytes
 */

// Verifies if a string corresponds to a built-in object name
predicate isBuiltinIdentifier(string name) { exists(Value val | val = Value::named(name) and val.isBuiltin()) }

// Determines if two names are identical and meet specific conditions
predicate areNamesIdentical(Name firstName, Name secondName) {
  checkExpressionEquivalence(firstName, secondName) and
  firstName.getVariable() = secondName.getVariable() and
  not isBuiltinIdentifier(firstName.getId()) and
  not checkOuterScopeUndefinedStatus(secondName)
}

// Retrieves the class value of an attribute's object
ClassValue determineAttributeClass(Attribute attr) { attr.getObject().pointsTo().getClass() = result }

// Checks if an attribute represents a property access
predicate isPropertyAccess(Attribute attr) {
  determineAttributeClass(attr).lookup(attr.getName()) instanceof PropertyValue
}

// Determines if two attributes are identical and meet specific conditions
predicate areAttributesIdentical(Attribute firstAttr, Attribute secondAttr) {
  checkExpressionEquivalence(firstAttr, secondAttr) and
  firstAttr.getName() = secondAttr.getName() and
  evaluateExpressionEquality(firstAttr.getObject(), secondAttr.getObject()) and
  exists(determineAttributeClass(firstAttr)) and
  not isPropertyAccess(firstAttr)
}

// Prevents interference from magic comments in analysis
pragma[nomagic]
Comment locatePyflakesDirective() { result.getText().toLowerCase().matches("%pyflakes%") }

// Gets the line number of a file containing a Pyflakes directive
int getPyflakesDirectiveLine(File f) {
  locatePyflakesDirective().getLocation().hasLocationInfo(f.getAbsolutePath(), result, _, _, _)
}

// Checks if an assignment statement is marked with a Pyflakes directive
predicate isMarkedWithPyflakesDirective(AssignStmt assignmentStmt) {
  exists(Location loc |
    assignmentStmt.getLocation() = loc and
    loc.getStartLine() = getPyflakesDirectiveLine(loc.getFile())
  )
}

// Checks if the left-hand side attribute expression has side effects
predicate hasLeftHandSideSideEffects(Attribute lhsAttr) {
  exists(ClassValue cls, ClassValue superType |
    lhsAttr.getObject().pointsTo().getClass() = cls and
    superType = cls.getASuperType() and
    not superType.isBuiltin()
  |
    superType.declaresAttribute("__setattr__")
  )
}

// Main query: Finds self-assignments without Pyflakes directives and without side effects
from AssignStmt assignmentStmt, Expr leftSide, Expr rightSide
where
  extractAssignmentComponents(assignmentStmt, leftSide, rightSide) and
  evaluateExpressionEquality(leftSide, rightSide) and
  not isMarkedWithPyflakesDirective(assignmentStmt) and
  not hasLeftHandSideSideEffects(leftSide)
select assignmentStmt, "This assignment assigns a variable to itself."