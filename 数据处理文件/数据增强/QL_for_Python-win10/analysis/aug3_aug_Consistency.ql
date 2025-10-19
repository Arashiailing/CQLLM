/**
 * @name Consistency check
 * @description Comprehensive consistency validation across all code components. Should never return results.
 * @id py/consistency-check
 */

import python
import analysis.DefinitionTracking

// Predicate to identify method result uniqueness violations
predicate method_uniqueness_violation(int resultCount, string method, string issueDescription) {
  // Validate method against monitored list
  method in [
      "toString", "getLocation", "getNode", "getDefinition", "getEntryNode", "getOrigin",
      "getAnInferredType"
    ] and
  // Generate issue description based on result count
  (
    resultCount = 0 and issueDescription = "no results for " + method + "()"
    or
    resultCount in [2 .. 10] and issueDescription = resultCount.toString() + " results for " + method + "()"
  )
}

// AST node consistency validation
predicate ast_node_consistency(string nodeType, string issueDescription, string contextInfo) {
  exists(AstNode node | nodeType = node.getAQlClass() |
    // Validate toString uniqueness
    method_uniqueness_violation(count(node.toString()), "toString", issueDescription) and
    contextInfo = "at " + node.getLocation().toString()
    or
    // Validate location uniqueness
    method_uniqueness_violation(strictcount(node.getLocation()), "getLocation", issueDescription) and
    contextInfo = node.getLocation().toString()
    or
    // Verify location existence
    not exists(node.getLocation()) and
    not node.(Module).isPackage() and
    issueDescription = "no location" and
    contextInfo = node.toString()
  )
}

// Location consistency validation
predicate location_consistency(string locationType, string issueDescription, string contextInfo) {
  exists(Location loc | locationType = loc.getAQlClass() |
    // Validate toString uniqueness
    method_uniqueness_violation(count(loc.toString()), "toString", issueDescription) and 
    contextInfo = "at " + loc.toString()
    or
    // Verify toString existence
    not exists(loc.toString()) and
    issueDescription = "no toString" and
    (
      exists(AstNode node | node.getLocation() = loc |
        contextInfo = "a location of a " + node.getAQlClass()
      )
      or
      not exists(AstNode node | node.getLocation() = loc) and
      contextInfo = "a location"
    )
    or
    // Validate line ordering
    loc.getEndLine() < loc.getStartLine() and
    issueDescription = "end line before start line" and
    contextInfo = "at " + loc.toString()
    or
    // Validate column ordering
    loc.getEndLine() = loc.getStartLine() and
    loc.getEndColumn() < loc.getStartColumn() and
    issueDescription = "end column before start column" and
    contextInfo = "at " + loc.toString()
  )
}

// Control flow graph consistency validation
predicate cfg_consistency(string nodeType, string issueDescription, string contextInfo) {
  exists(ControlFlowNode node | nodeType = node.getAQlClass() |
    // Validate node mapping uniqueness
    method_uniqueness_violation(count(node.getNode()), "getNode", issueDescription) and
    contextInfo = "at " + node.getLocation().toString()
    or
    // Verify location existence
    not exists(node.getLocation()) and
    not exists(Module pkg | pkg.isPackage() | pkg.getEntryNode() = node or pkg.getAnExitNode() = node) and
    issueDescription = "no location" and
    contextInfo = node.toString()
    or
    // Validate attribute node value uniqueness
    method_uniqueness_violation(count(node.(AttrNode).getObject()), "getValue", issueDescription) and
    contextInfo = "at " + node.getLocation().toString()
  )
}

// Scope consistency validation
predicate scope_consistency(string scopeType, string issueDescription, string contextInfo) {
  exists(Scope currentScope | scopeType = currentScope.getAQlClass() |
    // Validate entry node uniqueness
    method_uniqueness_violation(count(currentScope.getEntryNode()), "getEntryNode", issueDescription) and
    contextInfo = "at " + currentScope.getLocation().toString()
    or
    // Validate toString uniqueness
    method_uniqueness_violation(count(currentScope.toString()), "toString", issueDescription) and
    contextInfo = "at " + currentScope.getLocation().toString()
    or
    // Validate location uniqueness
    method_uniqueness_violation(strictcount(currentScope.getLocation()), "getLocation", issueDescription) and
    contextInfo = "at " + currentScope.getLocation().toString()
    or
    // Verify location existence
    not exists(currentScope.getLocation()) and
    issueDescription = "no location" and
    contextInfo = currentScope.toString() and
    not currentScope.(Module).isPackage()
  )
}

// Helper function to describe built-in objects
string describe_builtin_object(Object builtinObject) {
  builtinObject.isBuiltin() and
  (
    result = builtinObject.toString()
    or
    not exists(builtinObject.toString()) and py_cobjectnames(builtinObject, result)
    or
    not exists(builtinObject.toString()) and
    not py_cobjectnames(builtinObject, _) and
    result = "builtin object of type " + builtinObject.getAnInferredType().toString()
    or
    not exists(builtinObject.toString()) and
    not py_cobjectnames(builtinObject, _) and
    not exists(builtinObject.getAnInferredType().toString()) and
    result = "builtin object"
  )
}

// Private predicate for introspected built-in objects
private predicate is_introspected_builtin(Object builtinObject) {
  /* Only check objects from the extractor, missing data for objects generated 
   * from C source code analysis is OK as it will be ignored if it doesn't 
   * match up with the introspected form. */
  py_cobject_sources(builtinObject, 0)
}

// Built-in object consistency validation
predicate builtin_object_consistency(string objectType, string issueDescription, string contextInfo) {
  exists(Object builtinObject |
    objectType = builtinObject.getAQlClass() and
    contextInfo = describe_builtin_object(builtinObject) and
    is_introspected_builtin(builtinObject)
  |
    // Verify type/name existence
    not exists(builtinObject.getAnInferredType()) and
    not py_cobjectnames(builtinObject, _) and
    issueDescription = "neither name nor type"
    or
    // Validate name uniqueness
    method_uniqueness_violation(count(string name | py_cobjectnames(builtinObject, name)), "name", issueDescription)
    or
    not exists(builtinObject.getAnInferredType()) and issueDescription = "no results for getAnInferredType"
    or
    not exists(builtinObject.toString()) and
    issueDescription = "no toString" and
    not exists(string name | name.matches("\\_semmle%") | py_special_objects(builtinObject, name)) and
    not builtinObject = unknownValue()
  )
}

// Source object consistency validation
predicate source_object_consistency(string objectType, string issueDescription, string contextInfo) {
  exists(Object sourceObject | objectType = sourceObject.getAQlClass() and not sourceObject.isBuiltin() |
    // Validate origin uniqueness
    method_uniqueness_violation(count(sourceObject.getOrigin()), "getOrigin", issueDescription) and
    contextInfo = "at " + sourceObject.getOrigin().getLocation().toString()
    or
    // Verify location existence
    not exists(sourceObject.getOrigin().getLocation()) and 
    issueDescription = "no location" and 
    contextInfo = "??"
    or
    not exists(sourceObject.toString()) and
    issueDescription = "no toString" and
    contextInfo = "at " + sourceObject.getOrigin().getLocation().toString()
    or
    // Check toString multiplicity
    strictcount(sourceObject.toString()) > 1 and 
    issueDescription = "multiple toStrings()" and 
    contextInfo = sourceObject.toString()
  )
}

// SSA consistency validation
predicate ssa_consistency(string varType, string issueDescription, string contextInfo) {
  /* Zero or one definitions of each SSA variable */
  exists(SsaVariable ssaVar | varType = ssaVar.getAQlClass() |
    // Validate definition uniqueness
    method_uniqueness_violation(strictcount(ssaVar.getDefinition()), "getDefinition", issueDescription) and
    contextInfo = ssaVar.getId()
  )
  or
  /* Dominance criterion: Definition must dominate all uses */
  exists(SsaVariable ssaVar, ControlFlowNode defNode, ControlFlowNode useNode |
    defNode = ssaVar.getDefinition() and 
    useNode = ssaVar.getAUse()
  |
    // Validate dominance relationship
    not defNode.strictlyDominates(useNode) and
    not defNode = useNode and
    not (exists(ssaVar.getAPhiInput()) and defNode = useNode) and
    varType = ssaVar.getAQlClass() and
    issueDescription = "a definition which does not dominate a use at " + useNode.getLocation() and
    contextInfo = ssaVar.getId() + " at " + ssaVar.getLocation()
  )
  or
  /* Minimality of phi nodes */
  exists(SsaVariable ssaVar |
    strictcount(ssaVar.getAPhiInput()) = 1 and
    ssaVar.getAPhiInput()
        .getDefinition()
        .getBasicBlock()
        .strictlyDominates(ssaVar.getDefinition().getBasicBlock())
  |
    varType = ssaVar.getAQlClass() and
    issueDescription = "a definition which is dominated by the definition of an incoming phi edge" and
    contextInfo = ssaVar.getId() + " at " + ssaVar.getLocation()
  )
}

// Function object consistency validation
predicate function_object_consistency(string funcType, string issueDescription, string contextInfo) {
  exists(FunctionObject functionObject | funcType = functionObject.getAQlClass() |
    contextInfo = functionObject.getName() and
    (
      // Validate descriptive string existence
      not exists(functionObject.descriptiveString()) and 
      issueDescription = "no descriptiveString()"
      or
      exists(int cnt | cnt = strictcount(functionObject.descriptiveString()) and cnt > 1 |
        issueDescription = cnt + " descriptiveString()s"
      )
    )
    or
    not exists(functionObject.getName()) and 
    contextInfo = "?" and 
    issueDescription = "no name"
  )
}

// Predicate to detect objects with multiple origins
predicate has_multiple_origins(Object object) {
  not object.isC() and
  not object instanceof ModuleObject and
  exists(ControlFlowNode useNode, Context ctx |
    strictcount(ControlFlowNode orig | useNode.refersTo(ctx, object, _, orig)) > 1
  )
}

// Predicate to detect intermediate origins
predicate has_intermediate_origin(ControlFlowNode useNode, ControlFlowNode intermediateNode, Object object) {
  exists(ControlFlowNode originNode, Context ctx | not intermediateNode = originNode |
    useNode.refersTo(ctx, object, _, intermediateNode) and
    intermediateNode.refersTo(ctx, object, _, originNode) and
    not strictcount(Object val | intermediateNode.(AttrNode).getObject().refersTo(val)) > 1
  )
}

// Points-to consistency validation
predicate points_to_consistency(string nodeType, string issueDescription, string contextInfo) {
  exists(Object object |
    has_multiple_origins(object) and
    nodeType = object.getAQlClass() and
    issueDescription = "multiple origins for an object" and
    contextInfo = object.toString()
  )
  or
  exists(ControlFlowNode useNode, ControlFlowNode intermediateNode |
    has_intermediate_origin(useNode, intermediateNode, _) and
    nodeType = useNode.getAQlClass() and
    issueDescription = "has intermediate origin " + intermediateNode and
    contextInfo = useNode.toString()
  )
}

// Jump-to-definition consistency validation
predicate jump_to_definition_consistency(string exprType, string issueDescription, string contextInfo) {
  issueDescription = "multiple (jump-to) definitions" and
  exists(Expr expression |
    strictcount(getUniqueDefinition(expression)) > 1 and
    exprType = expression.getAQlClass() and
    contextInfo = expression.toString()
  )
}

// File consistency validation
predicate file_consistency(string fileType, string issueDescription, string contextInfo) {
  exists(File file, Folder folder |
    fileType = file.getAQlClass() and
    issueDescription = "has same name as a folder" and
    contextInfo = file.getAbsolutePath() and
    contextInfo = folder.getAbsolutePath()
  )
  or
  exists(Container container |
    fileType = container.getAQlClass() and
    method_uniqueness_violation(count(container.toString()), "toString", issueDescription) and
    contextInfo = "file " + container.getAbsolutePath()
  )
}

// Class value consistency validation
predicate class_value_consistency(string classType, string issueDescription, string contextInfo) {
  exists(ClassValue classValue, ClassValue superClass, string attribute |
    contextInfo = classValue.getName() and
    superClass = classValue.getASuperType() and
    exists(superClass.lookup(attribute)) and
    not classValue.failedInference(_) and
    not exists(classValue.lookup(attribute)) and
    classType = classValue.getAQlClass() and
    issueDescription = "no attribute '" + attribute + "', but super type '" + superClass.getName() + "' does."
  )
}

// Main query combining all consistency checks
from string componentType, string issueDescription, string contextInfo
where
  ast_node_consistency(componentType, issueDescription, contextInfo) or
  location_consistency(componentType, issueDescription, contextInfo) or
  scope_consistency(componentType, issueDescription, contextInfo) or
  cfg_consistency(componentType, issueDescription, contextInfo) or
  ssa_consistency(componentType, issueDescription, contextInfo) or
  builtin_object_consistency(componentType, issueDescription, contextInfo) or
  source_object_consistency(componentType, issueDescription, contextInfo) or
  function_object_consistency(componentType, issueDescription, contextInfo) or
  points_to_consistency(componentType, issueDescription, contextInfo) or
  jump_to_definition_consistency(componentType, issueDescription, contextInfo) or
  file_consistency(componentType, issueDescription, contextInfo) or
  class_value_consistency(componentType, issueDescription, contextInfo)
select componentType + " " + contextInfo + " has " + issueDescription