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

// Represents statements invoking the __init__ method
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call initCall, Attribute initAttr | 
      initCall = this.getValue() and 
      initAttr = initCall.getFunc() and
      initAttr.getName() = "__init__"
    )
  }
}

// Identifies statements assigning to self attributes
predicate assignsToSelfAttribute(Stmt assignmentStmt, string attributeName) {
  exists(Attribute selfAttribute, Name selfVariable |
    selfVariable = selfAttribute.getObject() and
    assignmentStmt.contains(selfAttribute) and
    selfVariable.getId() = "self" and
    selfAttribute.getCtx() instanceof Store and
    selfAttribute.getName() = attributeName
  )
}

// Checks if two functions assign to the same attribute
predicate assignsSameAttribute(
  Stmt firstAssignment, 
  Stmt secondAssignment, 
  Function firstFunction, 
  Function secondFunction
) {
  exists(string commonAttr |
    firstAssignment.getScope() = firstFunction and
    secondAssignment.getScope() = secondFunction and
    assignsToSelfAttribute(firstAssignment, commonAttr) and
    assignsToSelfAttribute(secondAssignment, commonAttr)
  )
}

// Determines assignment position relative to __init__ calls
predicate isAssignmentRelativeToInitCall(
  Function initFunc, 
  AssignStmt attrAssign, 
  string relPos
) {
  attrAssign.getScope() = initFunc and
  assignsToSelfAttribute(attrAssign, _) and
  exists(Stmt container | 
    container.contains(attrAssign) or container = attrAssign
  |
    (
      // Assignment after superclass __init__ call
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initFunc and
        assignPos > initPos and
        container = initFunc.getStmt(assignPos) and
        initCall = initFunc.getStmt(initPos) and
        relPos = "superclass"
      )
      or
      // Assignment before subclass __init__ call
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initFunc and
        assignPos < initPos and
        container = initFunc.getStmt(assignPos) and
        initCall = initFunc.getStmt(initPos) and
        relPos = "subclass"
      )
    )
  )
}

// Detects attribute overwriting in inheritance hierarchy
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssignment, 
  AssignStmt overwrittenAssignment, 
  string attributeName, 
  string inheritanceRelation, 
  string sourceClassName
) {
  exists(
    FunctionObject superClassInitFunc, 
    FunctionObject subClassInitFunc, 
    ClassObject superClass, 
    ClassObject subClass,
    AssignStmt subClassAssignment,
    AssignStmt superClassAssignment
  |
    // Establish assignment relationships based on inheritance type
    (
      inheritanceRelation = "superclass" and
      sourceClassName = superClass.getName() and
      overwritingAssignment = subClassAssignment and
      overwrittenAssignment = superClassAssignment
      or
      inheritanceRelation = "subclass" and
      sourceClassName = subClass.getName() and
      overwritingAssignment = superClassAssignment and
      overwrittenAssignment = subClassAssignment
    ) and
    // Exclude class attributes unless overwritten in subclass
    (not exists(superClass.declaredAttribute(attributeName)) or inheritanceRelation = "subclass") and
    // Verify both classes have __init__ methods
    superClass.declaredAttribute("__init__") = superClassInitFunc and
    subClass.declaredAttribute("__init__") = subClassInitFunc and
    // Ensure inheritance relationship
    superClass = subClass.getASuperType() and
    // Check assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subClassInitFunc.getFunction(), subClassAssignment, inheritanceRelation) and
    // Confirm same attribute is assigned in both functions
    assignsSameAttribute(
      subClassAssignment, 
      superClassAssignment, 
      subClassInitFunc.getFunction(), 
      superClassInitFunc.getFunction()
    ) and
    // Verify overwritten assignment targets self attribute
    assignsToSelfAttribute(superClassAssignment, attributeName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceRelation, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string sourceClassName
where isInheritanceAttributeOverwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceRelation, sourceClassName)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceRelation +
    " $@.", overwrittenAssignment, sourceClassName