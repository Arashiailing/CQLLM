/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Detects assignments to self attributes that overwrite attributes previously defined in subclass or superclass `__init__` method.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision medium
 * @id py/overwritten-inherited-attribute
 */

import python

/**
 * Represents statements that call the `__init__` method.
 * This identifies initialization calls within constructors.
 */
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call call, Attribute attr | 
      call = this.getValue() and 
      attr = call.getFunc() and
      attr.getName() = "__init__"
    )
  }
}

/**
 * Determines if an assignment overwrites an attribute in a superclass or subclass.
 * @param subclassInit The subclass initialization function containing the assignment
 * @param attributeAssignment The assignment statement that overwrites the attribute
 * @param overwrittenType Indicates whether the overwritten attribute was in "superclass" or "subclass"
 */
predicate overwrites_which(Function subclassInit, AssignStmt attributeAssignment, string overwrittenType) {
  attributeAssignment.getScope() = subclassInit and
  self_write_stmt(attributeAssignment, _) and
  exists(Stmt containingStmt | 
    containingStmt.contains(attributeAssignment) or containingStmt = attributeAssignment
  |
    (
      // Case 1: Overwrites superclass attribute (assignment follows super().__init__())
      exists(int assignIndex, int initIndex, InitCallStmt initCall | 
        initCall.getScope() = subclassInit and
        assignIndex > initIndex and
        containingStmt = subclassInit.getStmt(assignIndex) and
        initCall = subclassInit.getStmt(initIndex) and
        overwrittenType = "superclass"
      )
      or
      // Case 2: Overwrites subclass attribute (assignment precedes super().__init__())
      exists(int assignIndex, int initIndex, InitCallStmt initCall | 
        initCall.getScope() = subclassInit and
        assignIndex < initIndex and
        containingStmt = subclassInit.getStmt(assignIndex) and
        initCall = subclassInit.getStmt(initIndex) and
        overwrittenType = "subclass"
      )
    )
  )
}

/**
 * Identifies statements that assign to a `self` attribute.
 * @param statement The assignment statement to check
 * @param attributeName The name of the attribute being assigned
 */
predicate self_write_stmt(Stmt statement, string attributeName) {
  exists(Attribute attribute, Name selfRef |
    selfRef = attribute.getObject() and
    statement.contains(attribute) and
    selfRef.getId() = "self" and
    attribute.getCtx() instanceof Store and
    attribute.getName() = attributeName
  )
}

/**
 * Checks if two functions assign to the same attribute name.
 * @param stmt1 First statement (from first function)
 * @param stmt2 Second statement (from second function)
 * @param func1 First function containing the statement
 * @param func2 Second function containing the statement
 */
predicate both_assign_attribute(Stmt stmt1, Stmt stmt2, Function func1, Function func2) {
  exists(string attributeName |
    stmt1.getScope() = func1 and
    stmt2.getScope() = func2 and
    self_write_stmt(stmt1, attributeName) and
    self_write_stmt(stmt2, attributeName)
  )
}

/**
 * Identifies cases where an attribute assignment overwrites an inherited attribute.
 * @param overwritingStmt The assignment that performs the overwrite
 * @param overwrittenStmt The original assignment being overwritten
 * @param attributeName Name of the attribute being overwritten
 * @param overwrittenType Type of class containing original attribute ("superclass" or "subclass")
 * @param className Name of the class containing the original attribute
 */
predicate attribute_overwritten(
  AssignStmt overwritingStmt, AssignStmt overwrittenStmt, string attributeName, 
  string overwrittenType, string className
) {
  exists(
    FunctionObject superInit, FunctionObject subInit, 
    ClassObject superClass, ClassObject subClass,
    AssignStmt subAttrAssign, AssignStmt superAttrAssign
  |
    // Determine relationship between assignments and class types
    (
      // Case 1: Overwriting superclass attribute
      overwrittenType = "superclass" and
      className = superClass.getName() and
      overwritingStmt = subAttrAssign and
      overwrittenStmt = superAttrAssign
      or
      // Case 2: Overwriting subclass attribute
      overwrittenType = "subclass" and
      className = subClass.getName() and
      overwritingStmt = superAttrAssign and
      overwrittenStmt = subAttrAssign
    ) and
    // Validate class hierarchy and initialization methods
    superClass.declaredAttribute("__init__") = superInit and
    subClass.declaredAttribute("__init__") = subInit and
    superClass = subClass.getASuperType() and
    // Ensure overwritten attribute isn't a class-level attribute (unless in subclass)
    (not exists(superClass.declaredAttribute(attributeName)) or overwrittenType = "subclass") and
    // Verify overwrite conditions
    overwrites_which(subInit.getFunction(), subAttrAssign, overwrittenType) and
    both_assign_attribute(subAttrAssign, superAttrAssign, subInit.getFunction(), superInit.getFunction()) and
    self_write_stmt(superAttrAssign, attributeName)
  )
}

// Main query to detect attribute overwrites
from string overwrittenType, AssignStmt overwritingStmt, AssignStmt overwrittenStmt, string attributeName, string className
where attribute_overwritten(overwritingStmt, overwrittenStmt, attributeName, overwrittenType, className)
select overwritingStmt,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + overwrittenType +
    " $@.", overwrittenStmt, className