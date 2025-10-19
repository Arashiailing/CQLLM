/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting multiple base classes with identically named attributes, potentially causing unexpected behavior through attribute overriding.
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
 * Such functions represent empty or no-op implementations.
 */
predicate is_no_op_function(PyFunctionObject fn) {
  not exists(Stmt stmt | stmt.getScope() = fn.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = fn.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly calls super() to invoke parent class methods.
 * This indicates intentional method chaining in inheritance hierarchies.
 */
predicate invokes_super_method(FunctionObject fn) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = fn.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = fn.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names exempt from conflict detection due to special cases.
 * These exemptions follow documented patterns or library recommendations.
 */
predicate is_exempted_attribute(string attrName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject childClass, ClassObject base1, ClassObject base2, 
  string attrName, int idx1, int idx2, 
  Object attrInBase1, Object attrInBase2
where
  // Ensure distinct base classes with ordered inheritance positions
  childClass.getBaseType(idx1) = base1 and
  childClass.getBaseType(idx2) = base2 and
  idx1 < idx2 and
  
  // Locate identically named attributes in both base classes
  attrInBase1 = base1.lookupAttribute(attrName) and
  attrInBase2 = base2.lookupAttribute(attrName) and
  attrInBase1 != attrInBase2 and
  
  // Exclude special methods (dunder methods) which are expected to be overridden
  not attrName.matches("\\_\\_%\\_\\_") and
  
  // Skip cases where first base class properly calls super() (safe overriding)
  not invokes_super_method(attrInBase1) and
  
  // Ignore empty functions in second base class (no real conflict introduced)
  not is_no_op_function(attrInBase2) and
  
  // Exclude exempted attributes with special handling patterns
  not is_exempted_attribute(attrName) and
  
  // Ensure no override relationship exists between attributes
  not attrInBase1.overrides(attrInBase2) and
  not attrInBase2.overrides(attrInBase1) and
  
  // Verify child class doesn't explicitly declare the attribute
  not childClass.declaresAttribute(attrName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()