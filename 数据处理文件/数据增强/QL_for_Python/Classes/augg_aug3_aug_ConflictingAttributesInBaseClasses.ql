/**
 * @name Conflicting attributes in base classes
 * @description Detects classes inheriting from multiple base classes where more than one base class defines the same attribute. Such conflicts can lead to unexpected behavior due to attribute resolution ambiguity.
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
  ClassObject subClass, 
  ClassObject firstBase, 
  ClassObject secondBase, 
  string attrName, 
  int firstOrder, 
  int secondOrder, 
  Object firstAttr, 
  Object secondAttr
where
  // Establish inheritance relationships with ordering
  subClass.getBaseType(firstOrder) = firstBase and
  subClass.getBaseType(secondOrder) = secondBase and
  firstOrder < secondOrder and  // Ensure distinct base classes
  
  // Identify conflicting attributes in different base classes
  firstAttr = firstBase.lookupAttribute(attrName) and
  secondAttr = secondBase.lookupAttribute(attrName) and
  firstAttr != secondAttr and
  
  // Filter non-problematic conflicts
  (
    // Exclude special methods and exempt attributes
    not attrName.matches("\\_\\_%\\_\\_") and
    not is_exempt_attribute(attrName) and
    
    // Verify derived class doesn't override the attribute
    not subClass.declaresAttribute(attrName) and
    
    // Ensure no override relationship between attributes
    not firstAttr.overrides(secondAttr) and
    not secondAttr.overrides(firstAttr) and
    
    // Skip if first base handles resolution via super()
    not invokes_super(firstAttr) and
    
    // Ignore trivial implementations in second base
    not is_empty_implementation(secondAttr)
  )
select subClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  firstAttr, firstAttr.toString(), 
  secondAttr, secondAttr.toString()