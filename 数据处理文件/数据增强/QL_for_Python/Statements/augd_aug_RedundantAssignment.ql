/**
 * @name Self-assignment detection
 * @description A variable is assigned to itself, which is a no-op operation and likely indicates a coding error.
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

// Recursively determine correspondence between expressions, including attribute objects
predicate expressionsCorrespond(Expr leftExpr, Expr rightExpr) {
  exists(AssignStmt assignment |
    assignment.getATarget() = leftExpr and assignment.getValue() = rightExpr
  )
  or
  exists(Attribute leftAttribute, Attribute rightAttribute |
    expressionsCorrespond(leftAttribute, rightAttribute) and
    leftExpr = leftAttribute.getObject() and
    rightExpr = rightAttribute.getObject()
  )
}

// Check if a name might be undefined in an outer scope
predicate potentiallyUndefinedInOuterScope(Name name) {
  exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = name | ssaVar.maybeUndefined())
}

/*
 * Protection against FPs in projects that offer compatibility between Python 2 and 3,
 * since many of them make assignments such as
 *
 * if PY2:
 *     bytes = str
 * else:
 *     bytes = bytes
 */

// Check if a string corresponds to a builtin object name
predicate isBuiltinName(string name) { 
  exists(Value builtinValue | builtinValue = Value::named(name) and builtinValue.isBuiltin()) 
}

// Determine if two names are identical and meet specific conditions
predicate namesIdentical(Name firstName, Name secondName) {
  expressionsCorrespond(firstName, secondName) and
  firstName.getVariable() = secondName.getVariable() and
  not isBuiltinName(firstName.getId()) and
  not potentiallyUndefinedInOuterScope(secondName)
}

// Get the type value of an attribute object
ClassValue attributeValueType(Attribute attr) { 
  attr.getObject().pointsTo().getClass() = result 
}

// Check if an attribute is a property access
predicate isPropertyAccess(Attribute attr) {
  attributeValueType(attr).lookup(attr.getName()) instanceof PropertyValue
}

// Determine if two attributes are identical and meet specific conditions
predicate attributesIdentical(Attribute firstAttr, Attribute secondAttr) {
  expressionsCorrespond(firstAttr, secondAttr) and
  firstAttr.getName() = secondAttr.getName() and
  (namesIdentical(firstAttr.getObject(), secondAttr.getObject()) or 
   attributesIdentical(firstAttr.getObject(), secondAttr.getObject())) and
  exists(attributeValueType(firstAttr)) and
  not isPropertyAccess(firstAttr)
}

// Prevent magic comments from interfering with analysis
pragma[nomagic]
Comment pyflakesMagicComment() { 
  result.getText().toLowerCase().matches("%pyflakes%") 
}

// Get the line number containing Pyflakes comments in a file
int pyflakesCommentLine(File f) {
  pyflakesMagicComment().getLocation().hasLocationInfo(f.getAbsolutePath(), result, _, _, _)
}

// Check if an assignment statement is marked with Pyflakes comments
predicate isPyflakesCommented(AssignStmt assignmentStmt) {
  exists(Location loc |
    assignmentStmt.getLocation() = loc and
    loc.getStartLine() = pyflakesCommentLine(loc.getFile())
  )
}

// Check if the left-hand side attribute expression has side effects
predicate lhsHasSideEffects(Attribute lhsAttribute) {
  exists(ClassValue targetClass, ClassValue parentClass |
    lhsAttribute.getObject().pointsTo().getClass() = targetClass and
    parentClass = targetClass.getASuperType() and
    not parentClass.isBuiltin()
  |
    parentClass.declaresAttribute("__setattr__")
  )
}

// Main query: Find self-assignments without Pyflakes comments and without side effects
from AssignStmt assignmentStmt, Expr lhsExpr, Expr rhsExpr
where
  assignmentStmt.getATarget() = lhsExpr and assignmentStmt.getValue() = rhsExpr and
  (namesIdentical(lhsExpr, rhsExpr) or attributesIdentical(lhsExpr, rhsExpr)) and
  not isPyflakesCommented(assignmentStmt) and
  not lhsHasSideEffects(lhsExpr)
select assignmentStmt, "This assignment assigns a variable to itself."