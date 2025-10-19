/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes that define the same attribute. Such conflicts can cause unpredictable behavior due to ambiguous attribute resolution in multiple inheritance hierarchies.
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
 * Determines if a Python function implementation is effectively empty.
 * A function is considered empty if its body contains only pass statements or docstrings.
 */
predicate is_empty_implementation(PyFunctionObject function) {
  // Verify no non-trivial statements exist in function body
  not exists(Stmt stmt | stmt.getScope() = function.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly invokes super() for method resolution.
 * This indicates the function is designed to work in multiple inheritance scenarios
 * by properly calling the parent class implementation.
 */
predicate invokes_super(FunctionObject function) {
  // Identify super().method_name() pattern in function body
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = function.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = function.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names exempt from conflict detection.
 * These attributes have known usage patterns in multiple inheritance scenarios
 * where conflicts are expected and handled appropriately.
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for process_request as documented in Python's socketserver module:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   * This attribute is intentionally overridden in multiple inheritance patterns
   * and does not represent a problematic conflict.
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int baseOrder1, 
  int baseOrder2, 
  Object attribute1, 
  Object attribute2
where
  // Establish inheritance relationships with ordering
  derivedClass.getBaseType(baseOrder1) = baseClass1 and
  derivedClass.getBaseType(baseOrder2) = baseClass2 and
  baseOrder1 < baseOrder2 and  // Ensure distinct base classes
  
  // Identify conflicting attributes in different base classes
  attribute1 = baseClass1.lookupAttribute(attributeName) and
  attribute2 = baseClass2.lookupAttribute(attributeName) and
  attribute1 != attribute2 and
  
  // Filter non-problematic conflicts
  (
    // Exclude special methods and exempt attributes
    not attributeName.matches("\\_\\_%\\_\\_") and
    not is_exempt_attribute(attributeName) and
    
    // Verify derived class doesn't override the attribute
    not derivedClass.declaresAttribute(attributeName) and
    
    // Ensure no override relationship between attributes
    not attribute1.overrides(attribute2) and
    not attribute2.overrides(attribute1) and
    
    // Skip if first base handles resolution via super()
    not invokes_super(attribute1) and
    
    // Ignore trivial implementations in second base
    not is_empty_implementation(attribute2)
  )
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attribute1, attribute1.toString(), 
  attribute2, attribute2.toString()