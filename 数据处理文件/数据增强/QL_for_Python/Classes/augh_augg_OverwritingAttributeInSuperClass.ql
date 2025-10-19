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
 * Represents statements that invoke the `__init__` method.
 * This captures initialization calls within class constructors.
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
 * Determines whether an assignment statement overwrites an attribute
 * that was previously defined in either a superclass or subclass.
 * @param initMethod The initialization function containing the assignment
 * @param attrAssignment The assignment statement that potentially overwrites an attribute
 * @param targetClassType Specifies whether the overwritten attribute was defined in "superclass" or "subclass"
 */
predicate determines_overwrite_target(Function initMethod, AssignStmt attrAssignment, string targetClassType) {
  attrAssignment.getScope() = initMethod and
  self_attribute_assignment(attrAssignment, _) and
  exists(Stmt containerStmt | 
    containerStmt.contains(attrAssignment) or containerStmt = attrAssignment
  |
    (
      // Scenario 1: Overwriting a superclass attribute (assignment occurs after super().__init__())
      exists(int assignPos, int initCallPos, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignPos > initCallPos and
        containerStmt = initMethod.getStmt(assignPos) and
        initCall = initMethod.getStmt(initCallPos) and
        targetClassType = "superclass"
      )
      or
      // Scenario 2: Overwriting a subclass attribute (assignment occurs before super().__init__())
      exists(int assignPos, int initCallPos, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignPos < initCallPos and
        containerStmt = initMethod.getStmt(assignPos) and
        initCall = initMethod.getStmt(initCallPos) and
        targetClassType = "subclass"
      )
    )
  )
}

/**
 * Identifies statements that assign a value to a `self` attribute.
 * @param assignment The assignment statement to examine
 * @param attrName The name of the attribute being assigned
 */
predicate self_attribute_assignment(Stmt assignment, string attrName) {
  exists(Attribute attribute, Name selfReference |
    selfReference = attribute.getObject() and
    assignment.contains(attribute) and
    selfReference.getId() = "self" and
    attribute.getCtx() instanceof Store and
    attribute.getName() = attrName
  )
}

/**
 * Verifies if two functions assign values to the same attribute name.
 * @param firstStmt First assignment statement (from the first function)
 * @param secondStmt Second assignment statement (from the second function)
 * @param firstFunc First function containing the assignment
 * @param secondFunc Second function containing the assignment
 */
predicate functions_assign_to_same_attribute(Stmt firstStmt, Stmt secondStmt, Function firstFunc, Function secondFunc) {
  exists(string commonAttrName |
    firstStmt.getScope() = firstFunc and
    secondStmt.getScope() = secondFunc and
    self_attribute_assignment(firstStmt, commonAttrName) and
    self_attribute_assignment(secondStmt, commonAttrName)
  )
}

/**
 * Detects cases where an attribute assignment overwrites an inherited attribute.
 * @param overwritingAssignment The assignment that performs the overwrite
 * @param originalAssignment The original assignment being overwritten
 * @param attrName Name of the attribute being overwritten
 * @param classType Type of class containing the original attribute ("superclass" or "subclass")
 * @param containingClassName Name of the class containing the original attribute
 */
predicate detects_attribute_overwrite(
  AssignStmt overwritingAssignment, AssignStmt originalAssignment, string attrName, 
  string classType, string containingClassName
) {
  exists(
    FunctionObject parentInit, FunctionObject childInit, 
    ClassObject parentClass, ClassObject childClass,
    AssignStmt childAttrAssign, AssignStmt parentAttrAssign
  |
    // Establish relationship between assignments and class hierarchy
    (
      // Case 1: Overwriting a parent class attribute
      classType = "superclass" and
      containingClassName = parentClass.getName() and
      overwritingAssignment = childAttrAssign and
      originalAssignment = parentAttrAssign
      or
      // Case 2: Overwriting a child class attribute
      classType = "subclass" and
      containingClassName = childClass.getName() and
      overwritingAssignment = parentAttrAssign and
      originalAssignment = childAttrAssign
    ) and
    // Validate class hierarchy and initialization methods
    parentClass.declaredAttribute("__init__") = parentInit and
    childClass.declaredAttribute("__init__") = childInit and
    parentClass = childClass.getASuperType() and
    // Ensure the overwritten attribute isn't a class-level attribute (unless in subclass)
    (not exists(parentClass.declaredAttribute(attrName)) or classType = "subclass") and
    // Verify overwrite conditions
    determines_overwrite_target(childInit.getFunction(), childAttrAssign, classType) and
    functions_assign_to_same_attribute(childAttrAssign, parentAttrAssign, childInit.getFunction(), parentInit.getFunction()) and
    self_attribute_assignment(parentAttrAssign, attrName)
  )
}

// Main query to identify attribute overwrites
from string classType, AssignStmt overwritingAssignment, AssignStmt originalAssignment, string attrName, string containingClassName
where detects_attribute_overwrite(overwritingAssignment, originalAssignment, attrName, classType, containingClassName)
select overwritingAssignment,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + classType +
    " $@.", originalAssignment, containingClassName