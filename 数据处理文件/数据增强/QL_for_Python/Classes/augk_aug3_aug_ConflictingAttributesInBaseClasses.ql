/**
 * @name Conflicting attributes in base classes
 * @description Detects classes that inherit from multiple base classes where more than one base class defines the same attribute. Such conflicts can lead to unexpected behavior due to attribute resolution ambiguity.
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
  // Identify super().method_name() call pattern in function body
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
 * These attributes have known patterns of usage in multiple inheritance scenarios
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
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttributeName, 
  int firstInheritanceOrder, 
  int secondInheritanceOrder, 
  Object attributeInFirstBase, 
  Object attributeInSecondBase
where
  // Establish inheritance relationships between derived class and its base classes
  derivedClass.getBaseType(firstInheritanceOrder) = firstBaseClass and
  derivedClass.getBaseType(secondInheritanceOrder) = secondBaseClass and
  
  // Ensure distinct base classes ordered by inheritance position
  firstInheritanceOrder < secondInheritanceOrder and
  
  // Identify conflicting attributes in different base classes
  attributeInFirstBase = firstBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeInSecondBase = secondBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Filter out non-problematic conflicts
  not conflictingAttributeName.matches("\\_\\_%\\_\\_") and           // Exclude special methods
  not is_exempt_attribute(conflictingAttributeName) and              // Exclude known exempt attributes
  not derivedClass.declaresAttribute(conflictingAttributeName) and   // Ensure derived class doesn't override
  not attributeInFirstBase.overrides(attributeInSecondBase) and      // No override relationship between attributes
  not attributeInSecondBase.overrides(attributeInFirstBase) and
  not invokes_super(attributeInFirstBase) and                        // Skip if first base handles resolution
  not is_empty_implementation(attributeInSecondBase)                 // Ignore trivial implementations in second base
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()