/**
 * @name Redundant assignment
 * @description Identifies assignments where a variable is assigned to itself, which is typically useless and indicates a coding error.
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

// Determines if a statement is an assignment and extracts its target and value
predicate isAssignmentStatement(AssignStmt assignmentStmt, Expr lhs, Expr rhs) {
  assignmentStmt.getATarget() = lhs and assignmentStmt.getValue() = rhs
}

// Recursively checks if two expressions correspond to each other, including attribute objects
predicate expressionsMatch(Expr leftExpr, Expr rightExpr) {
  isAssignmentStatement(_, leftExpr, rightExpr)
  or
  exists(Attribute leftAttr, Attribute rightAttr |
    expressionsMatch(leftAttr, rightAttr) and
    leftExpr = leftAttr.getObject() and
    rightExpr = rightAttr.getObject()
  )
}

// Determines if two expressions have the same value (either identical names or attributes)
predicate expressionsHaveSameValue(Expr leftExpr, Expr rightExpr) {
  namesAreIdentical(leftExpr, rightExpr) or attributesAreIdentical(leftExpr, rightExpr)
}

// Checks if a name might be undefined in an outer scope
predicate isPotentiallyUndefinedInOuterScope(Name name) {
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

// Checks if a string corresponds to a built-in object name
predicate isBuiltInName(string name) { exists(Value val | val = Value::named(name) and val.isBuiltin()) }

// Determines if two names are identical and meet specific conditions
predicate namesAreIdentical(Name firstName, Name secondName) {
  expressionsMatch(firstName, secondName) and
  firstName.getVariable() = secondName.getVariable() and
  not isBuiltInName(firstName.getId()) and
  not isPotentiallyUndefinedInOuterScope(secondName)
}

// Retrieves the type value of an attribute's object
ClassValue getAttributeType(Attribute attr) { attr.getObject().pointsTo().getClass() = result }

// Checks if an attribute is a property access
predicate isProperty(Attribute attr) {
  getAttributeType(attr).lookup(attr.getName()) instanceof PropertyValue
}

// Determines if two attributes are identical and meet specific conditions
predicate attributesAreIdentical(Attribute firstAttr, Attribute secondAttr) {
  expressionsMatch(firstAttr, secondAttr) and
  firstAttr.getName() = secondAttr.getName() and
  expressionsHaveSameValue(firstAttr.getObject(), secondAttr.getObject()) and
  exists(getAttributeType(firstAttr)) and
  not isProperty(firstAttr)
}

// Prevents interference from magic comments in analysis
pragma[nomagic]
Comment findPyflakesMagicComment() { result.getText().toLowerCase().matches("%pyflakes%") }

// Gets the line number of a file containing a Pyflakes comment
int getPyflakesCommentLine(File f) {
  findPyflakesMagicComment().getLocation().hasLocationInfo(f.getAbsolutePath(), result, _, _, _)
}

// Checks if an assignment statement is marked with a Pyflakes comment
predicate hasPyflakesComment(AssignStmt assignmentStmt) {
  exists(Location loc |
    assignmentStmt.getLocation() = loc and
    loc.getStartLine() = getPyflakesCommentLine(loc.getFile())
  )
}

// Checks if the left-hand side attribute expression has side effects
predicate leftHandSideHasSideEffects(Attribute lhsAttr) {
  exists(ClassValue cls, ClassValue superType |
    lhsAttr.getObject().pointsTo().getClass() = cls and
    superType = cls.getASuperType() and
    not superType.isBuiltin()
  |
    superType.declaresAttribute("__setattr__")
  )
}

// Main query: Finds self-assignments without Pyflakes comments and without side effects
from AssignStmt assignmentStmt, Expr lhs, Expr rhs
where
  isAssignmentStatement(assignmentStmt, lhs, rhs) and
  expressionsHaveSameValue(lhs, rhs) and
  not hasPyflakesComment(assignmentStmt) and
  not leftHandSideHasSideEffects(lhs)
select assignmentStmt, "This assignment assigns a variable to itself."