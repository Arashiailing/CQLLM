/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting multiple base classes that define the same attribute, potentially causing unexpected behavior due to attribute overriding.
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
 * Determines if a Python function contains only pass statements and docstrings.
 * Such functions are considered empty implementations without meaningful logic.
 */
predicate is_no_op_function(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly uses super() to invoke parent class methods.
 * This indicates intentional method chaining in inheritance hierarchies.
 */
predicate invokes_super_method(FunctionObject func) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names exempt from conflict detection due to special handling patterns.
 * These exemptions follow documented conventions or library recommendations.
 */
predicate is_exempted_attribute(string attrName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject childClass, ClassObject baseClass1, ClassObject baseClass2, 
  string attrName, int baseIndex1, int baseIndex2, 
  Object attrInBase1, Object attrInBase2
where
  // Verify distinct base classes with ordered inheritance positions
  childClass.getBaseType(baseIndex1) = baseClass1 and
  childClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  
  // Find attributes with identical names in both base classes
  attrInBase1 = baseClass1.lookupAttribute(attrName) and
  attrInBase2 = baseClass2.lookupAttribute(attrName) and
  attrInBase1 != attrInBase2 and
  
  // Exclude special methods (dunder methods) which are designed for overriding
  not attrName.matches("\\_\\_%\\_\\_") and
  
  // Skip cases where the first base class properly uses super() (safe overriding)
  not invokes_super_method(attrInBase1) and
  
  // Ignore empty functions in the second base class (no real conflict introduced)
  not is_no_op_function(attrInBase2) and
  
  // Exclude exempted attributes with special handling patterns
  not is_exempted_attribute(attrName) and
  
  // Ensure no override relationship exists between attributes
  not attrInBase1.overrides(attrInBase2) and
  not attrInBase2.overrides(attrInBase1) and
  
  // Verify the child class doesn't explicitly declare the attribute
  // (explicit declaration would resolve the conflict intentionally)
  not childClass.declaresAttribute(attrName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()