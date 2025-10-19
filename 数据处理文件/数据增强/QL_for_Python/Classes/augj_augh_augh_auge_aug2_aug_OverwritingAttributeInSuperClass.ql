/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Detects assignments to self attributes that overwrite attributes 
 *              previously defined in subclass or superclass `__init__` methods.
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
 * Represents statements that invoke the __init__ method.
 * Used to identify initialization calls within methods to determine
 * the relative order of attribute assignments.
 */
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call initCall, Attribute initAttr | 
      initCall = this.getValue() and 
      initAttr = initCall.getFunc() and
      initAttr.getName() = "__init__"
    )
  }
}

/**
 * Identifies statements that assign values to self attributes.
 * @param stmt The statement being checked for self attribute assignment.
 * @param attrName The name of the attribute being assigned to self.
 */
predicate assignsToSelfAttribute(Stmt stmt, string attrName) {
  exists(Attribute selfAttr, Name selfVar |
    selfVar = selfAttr.getObject() and
    stmt.contains(selfAttr) and
    selfVar.getId() = "self" and
    selfAttr.getCtx() instanceof Store and
    selfAttr.getName() = attrName
  )
}

/**
 * Determines the position of an attribute assignment relative to __init__ calls.
 * @param initMethod The __init__ method containing the assignments.
 * @param attrAssign The attribute assignment statement being evaluated.
 * @param relType The relationship type ("superclass" or "subclass").
 */
predicate isAssignmentRelativeToInitCall(
  Function initMethod, 
  AssignStmt attrAssign, 
  string relType
) {
  attrAssign.getScope() = initMethod and
  assignsToSelfAttribute(attrAssign, _) and
  exists(Stmt stmtContainer | 
    stmtContainer.contains(attrAssign) or stmtContainer = attrAssign
  |
    exists(int attrAssignPos, int initCallPos, InitCallStmt initCall | 
      initCall.getScope() = initMethod and
      stmtContainer = initMethod.getStmt(attrAssignPos) and
      initCall = initMethod.getStmt(initCallPos) and
      (
        // Case 1: Assignment occurs after superclass __init__ call
        relType = "superclass" and attrAssignPos > initCallPos
        or
        // Case 2: Assignment occurs before subclass __init__ call
        relType = "subclass" and attrAssignPos < initCallPos
      )
    )
  )
}

/**
 * Checks if two functions assign to the same attribute.
 * @param firstAssign The first assignment statement.
 * @param secondAssign The second assignment statement.
 * @param firstFunc The function containing the first assignment.
 * @param secondFunc The function containing the second assignment.
 */
predicate assignsSameAttribute(
  Stmt firstAssign, 
  Stmt secondAssign, 
  Function firstFunc, 
  Function secondFunc
) {
  exists(string commonAttrName |
    firstAssign.getScope() = firstFunc and
    secondAssign.getScope() = secondFunc and
    assignsToSelfAttribute(firstAssign, commonAttrName) and
    assignsToSelfAttribute(secondAssign, commonAttrName)
  )
}

/**
 * Detects attribute overwriting in inheritance hierarchy.
 * @param overwritingAssign The assignment that overwrites an attribute.
 * @param overwrittenAssign The assignment that is being overwritten.
 * @param attrName The name of the attribute being overwritten.
 * @param inhType The type of inheritance relationship ("superclass" or "subclass").
 * @param overwritingClass The name of the class where the overwriting occurs.
 */
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssign, 
  AssignStmt overwrittenAssign, 
  string attrName, 
  string inhType, 
  string overwritingClass
) {
  exists(
    FunctionObject superInit, 
    FunctionObject subInit, 
    ClassObject superClass, 
    ClassObject subClass,
    AssignStmt subAttrAssign,
    AssignStmt superAttrAssign
  |
    // Establish inheritance relationship and identify __init__ methods
    superClass = subClass.getASuperType() and
    superClass.declaredAttribute("__init__") = superInit and
    subClass.declaredAttribute("__init__") = subInit and
    
    // Determine assignment relationships based on inheritance type
    (
      inhType = "superclass" and
      overwritingClass = superClass.getName() and
      overwritingAssign = subAttrAssign and
      overwrittenAssign = superAttrAssign
      or
      inhType = "subclass" and
      overwritingClass = subClass.getName() and
      overwritingAssign = superAttrAssign and
      overwrittenAssign = subAttrAssign
    ) and
    
    // Exclude class attributes unless they are overwritten in subclass
    (not exists(superClass.declaredAttribute(attrName)) or inhType = "subclass") and
    
    // Verify assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subInit.getFunction(), subAttrAssign, inhType) and
    
    // Confirm the same attribute is assigned in both functions
    assignsSameAttribute(
      subAttrAssign, 
      superAttrAssign, 
      subInit.getFunction(), 
      superInit.getFunction()
    ) and
    
    // Ensure the overwritten assignment targets a self attribute
    assignsToSelfAttribute(superAttrAssign, attrName)
  )
}

// Main query: Identify attribute overwrites with contextual information
from string inhType, AssignStmt overwritingAssign, AssignStmt overwrittenAssign, string attrName, string overwritingClass
where isInheritanceAttributeOverwrite(overwritingAssign, overwrittenAssign, attrName, inhType, overwritingClass)
select overwritingAssign,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + inhType +
    " $@.", overwrittenAssign, overwritingClass