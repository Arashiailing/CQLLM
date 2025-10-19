/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Identifies assignments to instance attributes that overwrite attributes 
 *              previously defined in subclass or superclass initializers.
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
    exists(Call initInvocation, Attribute initMethodAttr | 
      initInvocation = this.getValue() and 
      initMethodAttr = initInvocation.getFunc() and
      initMethodAttr.getName() = "__init__"
    )
  }
}

// Identifies statements assigning to instance attributes
predicate assignsToInstanceAttribute(Stmt assignmentStmt, string attributeName) {
  exists(Attribute instanceAttribute, Name instanceVariable |
    instanceVariable = instanceAttribute.getObject() and
    assignmentStmt.contains(instanceAttribute) and
    instanceVariable.getId() = "self" and
    instanceAttribute.getCtx() instanceof Store and
    instanceAttribute.getName() = attributeName
  )
}

// Determines assignment position relative to __init__ calls
predicate getAssignmentPositionRelativeToInitCall(
  Function initMethod, 
  AssignStmt attributeAssignment, 
  string relativePosition
) {
  attributeAssignment.getScope() = initMethod and
  assignsToInstanceAttribute(attributeAssignment, _) and
  exists(Stmt containingStmt | 
    containingStmt.contains(attributeAssignment) or containingStmt = attributeAssignment
  |
    (
      // Assignment after superclass __init__ call
      exists(int assignmentPosition, int initCallPosition, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignmentPosition > initCallPosition and
        containingStmt = initMethod.getStmt(assignmentPosition) and
        initCall = initMethod.getStmt(initCallPosition) and
        relativePosition = "superclass"
      )
      or
      // Assignment before subclass __init__ call
      exists(int assignmentPosition, int initCallPosition, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignmentPosition < initCallPosition and
        containingStmt = initMethod.getStmt(assignmentPosition) and
        initCall = initMethod.getStmt(initCallPosition) and
        relativePosition = "subclass"
      )
    )
  )
}

// Checks if two functions assign to the same attribute
predicate assignToSameAttribute(
  Stmt firstAssignment, 
  Stmt secondAssignment, 
  Function firstFunction, 
  Function secondFunction
) {
  exists(string sharedAttributeName |
    firstAssignment.getScope() = firstFunction and
    secondAssignment.getScope() = secondFunction and
    assignsToInstanceAttribute(firstAssignment, sharedAttributeName) and
    assignsToInstanceAttribute(secondAssignment, sharedAttributeName)
  )
}

// Detects attribute overwriting in inheritance hierarchy
predicate isInstanceAttributeOverwriteInInheritance(
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
    getAssignmentPositionRelativeToInitCall(subClassInitFunc.getFunction(), subClassAssignment, inheritanceRelation) and
    // Confirm same attribute is assigned in both functions
    assignToSameAttribute(
      subClassAssignment, 
      superClassAssignment, 
      subClassInitFunc.getFunction(), 
      superClassInitFunc.getFunction()
    ) and
    // Verify overwritten assignment targets instance attribute
    assignsToInstanceAttribute(superClassAssignment, attributeName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceRelation, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string sourceClassName
where isInstanceAttributeOverwriteInInheritance(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceRelation, sourceClassName)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceRelation +
    " $@.", overwrittenAssignment, sourceClassName