/**
 * @name Redundant assignment
 * @description An assignment where a variable is assigned to itself is redundant and likely indicates a coding error.
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
predicate isAssignment(AssignStmt assignmentStmt, Expr lhs, Expr rhs) {
  assignmentStmt.getATarget() = lhs and assignmentStmt.getValue() = rhs
}

// Recursively determines correspondence between expressions including attribute objects
predicate expressionsCorrespond(Expr leftExpr, Expr rightExpr) {
  isAssignment(_, leftExpr, rightExpr)
  or
  exists(Attribute leftAttr, Attribute rightAttr |
    expressionsCorrespond(leftAttr, rightAttr) and
    leftExpr = leftAttr.getObject() and
    rightExpr = rightAttr.getObject()
  )
}

// Checks if two expressions have equivalent values (identical names or attributes)
predicate haveSameValue(Expr leftExpr, Expr rightExpr) {
  namesIdentical(leftExpr, rightExpr) or attributesIdentical(leftExpr, rightExpr)
}

// Detects names that might be undefined in outer scopes
predicate potentiallyUndefinedInOuterScope(Name varName) {
  exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = varName | ssaVar.maybeUndefined())
}

/*
 * Protection against FPs in projects offering Python 2/3 compatibility,
 * as they often contain assignments like:
 *
 * if PY2:
 *     bytes = str
 * else:
 *     bytes = bytes
 */

// Verifies if a name corresponds to a built-in object
predicate isBuiltinName(string name) { 
  exists(Value builtinValue | 
    builtinValue = Value::named(name) and builtinValue.isBuiltin() 
  ) 
}

// Determines if two names are identical under specific conditions
predicate namesIdentical(Name firstName, Name secondName) {
  expressionsCorrespond(firstName, secondName) and
  firstName.getVariable() = secondName.getVariable() and
  not isBuiltinName(firstName.getId()) and
  not potentiallyUndefinedInOuterScope(secondName)
}

// Retrieves the type value of an attribute's object
ClassValue attributeValueType(Attribute attribute) { 
  attribute.getObject().pointsTo().getClass() = result 
}

// Checks if an attribute represents a property access
predicate isPropertyAccess(Attribute attribute) {
  attributeValueType(attribute).lookup(attribute.getName()) instanceof PropertyValue
}

// Determines if two attributes are identical under specific conditions
predicate attributesIdentical(Attribute firstAttr, Attribute secondAttr) {
  expressionsCorrespond(firstAttr, secondAttr) and
  firstAttr.getName() = secondAttr.getName() and
  haveSameValue(firstAttr.getObject(), secondAttr.getObject()) and
  exists(attributeValueType(firstAttr)) and
  not isPropertyAccess(firstAttr)
}

// Prevents magic comments from interfering with analysis
pragma[nomagic]
Comment pyflakesMagicComment() { 
  result.getText().toLowerCase().matches("%pyflakes%") 
}

// Retrieves line numbers containing Pyflakes comments in a file
int pyflakesCommentLine(File file) {
  pyflakesMagicComment().getLocation().hasLocationInfo(file.getAbsolutePath(), result, _, _, _)
}

// Checks if an assignment statement is marked with a Pyflakes comment
predicate isPyflakesCommented(AssignStmt assignmentStmt) {
  exists(Location location |
    assignmentStmt.getLocation() = location and
    location.getStartLine() = pyflakesCommentLine(location.getFile())
  )
}

// Detects side effects in left-hand side attribute expressions
predicate lhsHasSideEffects(Attribute lhsAttr) {
  exists(ClassValue classType, ClassValue superClassType |
    lhsAttr.getObject().pointsTo().getClass() = classType and
    superClassType = classType.getASuperType() and
    not superClassType.isBuiltin()
  |
    superClassType.declaresAttribute("__setattr__")
  )
}

// Main query: Finds self-assignments without Pyflakes comments or side effects
from AssignStmt assignmentStmt, Expr lhs, Expr rhs
where
  isAssignment(assignmentStmt, lhs, rhs) and
  haveSameValue(lhs, rhs) and
  not isPyflakesCommented(assignmentStmt) and
  not lhsHasSideEffects(lhs)
select assignmentStmt, "This assignment assigns a variable to itself."