/**
 * @name Base class attribute conflicts
 * @description Detects derived classes inheriting multiple base classes with identically named attributes, potentially causing unintended behavior due to attribute overriding.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/conflicting-attributes
 */

import python

/**
 * Determines if a Python function contains only pass statements and docstrings,
 * indicating an empty implementation without substantial logic.
 */
predicate is_no_op_function(PyFunctionObject func) {
  not exists(Stmt stmt | 
    stmt.getScope() = func.getFunction() and
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Checks whether a function explicitly uses super() to invoke parent class methods,
 * indicating intentional method chaining in inheritance hierarchies.
 */
predicate invokes_super_method(FunctionObject func) {
  exists(Call superCall, Call methodCall, Attribute attrRef, GlobalVariable superGlobal |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attrRef and
    attrRef.getObject() = superCall and
    attrRef.getName() = func.getName() and
    superCall.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Identifies attribute names exempt from conflict detection due to special handling patterns,
 * following documented conventions or library recommendations.
 */
predicate is_exempted_attribute(string attrName) {
  /*
   * Exemption based on standard library guidance:
   * Refer to https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject childClass, ClassObject primaryBase, ClassObject secondaryBase, 
  string attrName, int primaryBaseIndex, int secondaryBaseIndex, 
  Object primaryBaseAttr, Object secondaryBaseAttr
where
  // Ensure distinct base classes with inheritance order
  childClass.getBaseType(primaryBaseIndex) = primaryBase and
  childClass.getBaseType(secondaryBaseIndex) = secondaryBase and
  primaryBaseIndex < secondaryBaseIndex and
  
  // Identify attributes with matching names in both base classes
  primaryBaseAttr = primaryBase.lookupAttribute(attrName) and
  secondaryBaseAttr = secondaryBase.lookupAttribute(attrName) and
  primaryBaseAttr != secondaryBaseAttr and
  
  // Exclude special methods (dunder methods) intended for overriding
  not attrName.matches("\\_\\_%\\_\\_") and
  
  // Skip cases where the first base class properly uses super() (indicating safe overriding)
  not invokes_super_method(primaryBaseAttr) and
  
  // Ignore empty functions in the second base class (which don't introduce real conflicts)
  not is_no_op_function(secondaryBaseAttr) and
  
  // Exclude attributes with special handling patterns (exempted)
  not is_exempted_attribute(attrName) and
  
  // Ensure no override relationship exists between the attributes
  not primaryBaseAttr.overrides(secondaryBaseAttr) and
  not secondaryBaseAttr.overrides(primaryBaseAttr) and
  
  // Verify the derived class does not explicitly declare the attribute
  // (explicit declaration would intentionally resolve the conflict)
  not childClass.declaresAttribute(attrName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  primaryBaseAttr, primaryBaseAttr.toString(), 
  secondaryBaseAttr, secondaryBaseAttr.toString()