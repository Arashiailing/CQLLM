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

// Extracts target and value from an assignment statement
predicate assignmentComponents(AssignStmt stmt, Expr target, Expr value) {
  stmt.getATarget() = target and stmt.getValue() = value
}

// Recursively matches expressions including attribute objects
predicate expressionEquivalent(Expr expr1, Expr expr2) {
  assignmentComponents(_, expr1, expr2)
  or
  exists(Attribute attr1, Attribute attr2 |
    expressionEquivalent(attr1, attr2) and
    expr1 = attr1.getObject() and
    expr2 = attr2.getObject()
  )
}

// Determines if two expressions represent the same value
predicate sameValue(Expr expr1, Expr expr2) {
  identicalNames(expr1, expr2) or identicalAttributes(expr1, expr2)
}

// Checks if a name might be undefined in outer scope
predicate potentiallyUndefined(Name name) {
  exists(SsaVariable var | var.getAUse().getNode() = name | var.maybeUndefined())
}

/*
 * Protection against false positives in Python 2/3 compatibility code:
 * if PY2:
 *     bytes = str
 * else:
 *     bytes = bytes
 */

// Identifies built-in object names
predicate builtinName(string name) { exists(Value val | val = Value::named(name) and val.isBuiltin()) }

// Checks if two names are identical under specific conditions
predicate identicalNames(Name name1, Name name2) {
  expressionEquivalent(name1, name2) and
  name1.getVariable() = name2.getVariable() and
  not builtinName(name1.getId()) and
  not potentiallyUndefined(name2)
}

// Retrieves the class value of an attribute's object
ClassValue attributeClass(Attribute attr) { attr.getObject().pointsTo().getClass() = result }

// Checks if an attribute is a property access
predicate isPropertyAccess(Attribute attr) {
  attributeClass(attr).lookup(attr.getName()) instanceof PropertyValue
}

// Checks if two attributes are identical under specific conditions
predicate identicalAttributes(Attribute attr1, Attribute attr2) {
  expressionEquivalent(attr1, attr2) and
  attr1.getName() = attr2.getName() and
  sameValue(attr1.getObject(), attr2.getObject()) and
  exists(attributeClass(attr1)) and
  not isPropertyAccess(attr1)
}

// Prevents magic comment interference in analysis
pragma[nomagic]
Comment pyflakesMagicComment() { result.getText().toLowerCase().matches("%pyflakes%") }

// Gets line number of Pyflakes comment in a file
int pyflakesCommentLine(File f) {
  pyflakesMagicComment().getLocation().hasLocationInfo(f.getAbsolutePath(), result, _, _, _)
}

// Checks if assignment has Pyflakes comment
predicate hasPyflakesAnnotation(AssignStmt stmt) {
  exists(Location loc |
    stmt.getLocation() = loc and
    loc.getStartLine() = pyflakesCommentLine(loc.getFile())
  )
}

// Checks if LHS attribute has potential side effects
predicate lhsSideEffects(Attribute attr) {
  exists(ClassValue cls, ClassValue superType |
    attr.getObject().pointsTo().getClass() = cls and
    superType = cls.getASuperType() and
    not superType.isBuiltin()
  |
    superType.declaresAttribute("__setattr__")
  )
}

// Main query: Identifies self-assignments without special annotations
from AssignStmt selfAssignment, Expr leftExpr, Expr rightExpr
where
  assignmentComponents(selfAssignment, leftExpr, rightExpr) and
  sameValue(leftExpr, rightExpr) and
  not hasPyflakesAnnotation(selfAssignment) and
  not lhsSideEffects(leftExpr)
select selfAssignment, "This assignment assigns a variable to itself."