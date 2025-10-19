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
 * @param relationType The relationship type ("superclass" or "subclass").
 */
predicate isAssignmentRelativeToInitCall(
  Function initMethod, 
  AssignStmt attrAssign, 
  string relationType
) {
  attrAssign.getScope() = initMethod and
  assignsToSelfAttribute(attrAssign, _) and
  exists(Stmt container | 
    container.contains(attrAssign) or container = attrAssign
  |
    (
      // Case 1: Assignment occurs after superclass __init__ call
      relationType = "superclass" and
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignPos > initPos and
        container = initMethod.getStmt(assignPos) and
        initCall = initMethod.getStmt(initPos)
      )
      or
      // Case 2: Assignment occurs before subclass __init__ call
      relationType = "subclass" and
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignPos < initPos and
        container = initMethod.getStmt(assignPos) and
        initCall = initMethod.getStmt(initPos)
      )
    )
  )
}

/**
 * Checks if two functions assign to the same attribute.
 * @param firstStmt The first assignment statement.
 * @param secondStmt The second assignment statement.
 * @param firstFunc The function containing the first assignment.
 * @param secondFunc The function containing the second assignment.
 */
predicate assignsSameAttribute(
  Stmt firstStmt, 
  Stmt secondStmt, 
  Function firstFunc, 
  Function secondFunc
) {
  exists(string commonAttrName |
    firstStmt.getScope() = firstFunc and
    secondStmt.getScope() = secondFunc and
    assignsToSelfAttribute(firstStmt, commonAttrName) and
    assignsToSelfAttribute(secondStmt, commonAttrName)
  )
}

/**
 * Detects attribute overwriting in inheritance hierarchy.
 * @param overwritingAssign The assignment that overwrites an attribute.
 * @param overwrittenAssign The assignment that is being overwritten.
 * @param attrName The name of the attribute being overwritten.
 * @param inheritanceType The type of inheritance relationship ("superclass" or "subclass").
 * @param className The name of the class where the overwriting occurs.
 */
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssign, 
  AssignStmt overwrittenAssign, 
  string attrName, 
  string inheritanceType, 
  string className
) {
  exists(
    FunctionObject superInitFunc, 
    FunctionObject subInitFunc, 
    ClassObject superClass, 
    ClassObject subClass,
    AssignStmt subclassAttrAssign,
    AssignStmt superclassAttrAssign
  |
    // Establish inheritance relationship and identify __init__ methods
    superClass = subClass.getASuperType() and
    superClass.declaredAttribute("__init__") = superInitFunc and
    subClass.declaredAttribute("__init__") = subInitFunc and
    
    // Determine assignment relationships based on inheritance type
    (
      inheritanceType = "superclass" and
      className = superClass.getName() and
      overwritingAssign = subclassAttrAssign and
      overwrittenAssign = superclassAttrAssign
      or
      inheritanceType = "subclass" and
      className = subClass.getName() and
      overwritingAssign = superclassAttrAssign and
      overwrittenAssign = subclassAttrAssign
    ) and
    
    // Exclude class attributes unless they are overwritten in subclass
    (not exists(superClass.declaredAttribute(attrName)) or inheritanceType = "subclass") and
    
    // Verify assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subInitFunc.getFunction(), subclassAttrAssign, inheritanceType) and
    
    // Confirm the same attribute is assigned in both functions
    assignsSameAttribute(
      subclassAttrAssign, 
      superclassAttrAssign, 
      subInitFunc.getFunction(), 
      superInitFunc.getFunction()
    ) and
    
    // Ensure the overwritten assignment targets a self attribute
    assignsToSelfAttribute(superclassAttrAssign, attrName)
  )
}

// Main query: Identify attribute overwrites with contextual information
from string inheritanceType, AssignStmt overwritingAssign, AssignStmt overwrittenAssign, string attrName, string className
where isInheritanceAttributeOverwrite(overwritingAssign, overwrittenAssign, attrName, inheritanceType, className)
select overwritingAssign,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + inheritanceType +
    " $@.", overwrittenAssign, className