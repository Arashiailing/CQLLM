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

// Extracts left-hand side and right-hand side expressions from assignment statements
predicate getAssignmentComponents(AssignStmt assignmentStmt, Expr lhs, Expr rhs) {
  assignmentStmt.getATarget() = lhs and assignmentStmt.getValue() = rhs
}

// Recursively checks equivalence between expressions including attribute objects
predicate areExpressionsEquivalent(Expr left, Expr right) {
  getAssignmentComponents(_, left, right)
  or
  exists(Attribute attr1, Attribute attr2 |
    areExpressionsEquivalent(attr1, attr2) and
    left = attr1.getObject() and
    right = attr2.getObject()
  )
}

// Determines if two expressions represent semantically equivalent values
predicate representSameValue(Expr left, Expr right) {
  areNamesIdentical(left, right) or areAttributesIdentical(left, right)
}

// Checks if a variable name might be undefined in outer scope
predicate isPotentiallyUndefined(Name varName) {
  exists(SsaVariable var | var.getAUse().getNode() = varName | var.maybeUndefined())
}

/*
 * Protection against false positives in Python 2/3 compatibility code:
 * if PY2:
 *     bytes = str
 * else:
 *     bytes = bytes
 */

// Identifies built-in object names
predicate isBuiltinName(string builtinNameStr) { 
  exists(Value val | val = Value::named(builtinNameStr) and val.isBuiltin()) 
}

// Verifies if two names are identical under specific conditions
predicate areNamesIdentical(Name firstName, Name secondName) {
  areExpressionsEquivalent(firstName, secondName) and
  firstName.getVariable() = secondName.getVariable() and
  not isBuiltinName(firstName.getId()) and
  not isPotentiallyUndefined(secondName)
}

// Retrieves the class value of an attribute's object
ClassValue getAttributeClass(Attribute attribute) { 
  attribute.getObject().pointsTo().getClass() = result 
}

// Checks if an attribute represents a property access
predicate isPropertyAccess(Attribute attribute) {
  getAttributeClass(attribute).lookup(attribute.getName()) instanceof PropertyValue
}

// Verifies if two attributes are identical under specific conditions
predicate areAttributesIdentical(Attribute firstAttr, Attribute secondAttr) {
  areExpressionsEquivalent(firstAttr, secondAttr) and
  firstAttr.getName() = secondAttr.getName() and
  representSameValue(firstAttr.getObject(), secondAttr.getObject()) and
  exists(getAttributeClass(firstAttr)) and
  not isPropertyAccess(firstAttr)
}

// Prevents magic comment interference in analysis
pragma[nomagic]
Comment getPyflakesMagicComment() { 
  result.getText().toLowerCase().matches("%pyflakes%") 
}

// Gets line number of Pyflakes comment in a file
int getPyflakesCommentLine(File file) {
  getPyflakesMagicComment().getLocation().hasLocationInfo(
    file.getAbsolutePath(), result, _, _, _
  )
}

// Checks if assignment statement has Pyflakes annotation
predicate hasPyflakesAnnotation(AssignStmt assignmentStmt) {
  exists(Location loc |
    assignmentStmt.getLocation() = loc and
    loc.getStartLine() = getPyflakesCommentLine(loc.getFile())
  )
}

// Checks if left-hand side attribute has potential side effects
predicate hasLhsSideEffects(Attribute attribute) {
  exists(ClassValue cls, ClassValue superType |
    attribute.getObject().pointsTo().getClass() = cls and
    superType = cls.getASuperType() and
    not superType.isBuiltin()
  |
    superType.declaresAttribute("__setattr__")
  )
}

// Main query: Identifies self-assignments without special annotations
from AssignStmt assignStmt, Expr lhs, Expr rhs
where
  getAssignmentComponents(assignStmt, lhs, rhs) and
  representSameValue(lhs, rhs) and
  not hasPyflakesAnnotation(assignStmt) and
  not hasLhsSideEffects(lhs)
select assignStmt, "This assignment assigns a variable to itself."