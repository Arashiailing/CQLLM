/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute, which may lead to unexpected behavior due to attribute overriding.
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
 * Identifies functions that contain only pass statements and docstrings.
 * These are considered empty implementations without meaningful operations.
 */
predicate is_empty_function(PyFunctionObject funcObj) {
  not exists(Stmt statement | statement.getScope() = funcObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Determines if a function explicitly invokes parent class methods using super().
 * This indicates intentional method chaining in inheritance hierarchies.
 */
predicate calls_super_method(FunctionObject funcObj) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = funcObj.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = funcObj.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names excluded from conflict detection due to special cases.
 * These exemptions follow documented patterns or library-specific conventions.
 */
predicate is_attribute_exempted(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject childClass, ClassObject baseClass1, ClassObject baseClass2, 
  string attrName, int baseIndex1, int baseIndex2, 
  Object attrInBase1, Object attrInBase2
where
  // Ensure distinct base classes with ordered inheritance positions
  childClass.getBaseType(baseIndex1) = baseClass1 and
  childClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  
  // Locate conflicting attributes in base classes
  attrInBase1 = baseClass1.lookupAttribute(attrName) and
  attrInBase2 = baseClass2.lookupAttribute(attrName) and
  attrInBase1 != attrInBase2 and
  
  // Exclude special methods (dunder methods) which are expected to be overridden
  not attrName.matches("\\_\\_%\\_\\_") and
  
  // Exclude cases where first base class properly calls super()
  not calls_super_method(attrInBase1) and
  
  // Ignore empty functions in second base class (no real conflict)
  not is_empty_function(attrInBase2) and
  
  // Skip exempted attributes with special handling patterns
  not is_attribute_exempted(attrName) and
  
  // Ensure no override relationship exists between attributes
  not attrInBase1.overrides(attrInBase2) and
  not attrInBase2.overrides(attrInBase1) and
  
  // Verify derived class doesn't explicitly declare the attribute
  not childClass.declaresAttribute(attrName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()