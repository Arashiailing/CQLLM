/**
 * @name Consistency check
 * @description General consistency check to be run on any and all code. Should never produce any results.
 * @id py/consistency-check
 */

import python
import analysis.DefinitionTracking

// Predicate to detect uniqueness violations in method results
predicate uniqueness_error(int resultCount, string method, string description) {
  // Check if method is in the monitored list
  method in [
      "toString", "getLocation", "getNode", "getDefinition", "getEntryNode", "getOrigin",
      "getAnInferredType"
    ] and
  // Define issue description based on result count
  (
    resultCount = 0 and description = "no results for " + method + "()"
    or
    resultCount in [2 .. 10] and description = resultCount.toString() + " results for " + method + "()"
  )
}

// AST consistency validation
predicate ast_consistency(string nodeClass, string issueDesc, string details) {
  exists(AstNode node | nodeClass = node.getAQlClass() |
    // Check toString uniqueness
    uniqueness_error(count(node.toString()), "toString", issueDesc) and
    details = "at " + node.getLocation().toString()
    or
    // Check location uniqueness
    uniqueness_error(strictcount(node.getLocation()), "getLocation", issueDesc) and
    details = node.getLocation().toString()
    or
    // Validate location existence
    not exists(node.getLocation()) and
    not node.(Module).isPackage() and
    issueDesc = "no location" and
    details = node.toString()
  )
}

// Location consistency validation
predicate location_consistency(string locClass, string issueDesc, string details) {
  exists(Location location | locClass = location.getAQlClass() |
    // Check toString uniqueness
    uniqueness_error(count(location.toString()), "toString", issueDesc) and 
    details = "at " + location.toString()
    or
    // Validate toString existence
    not exists(location.toString()) and
    issueDesc = "no toString" and
    (
      exists(AstNode node | node.getLocation() = location |
        details = "a location of a " + node.getAQlClass()
      )
      or
      not exists(AstNode node | node.getLocation() = location) and
      details = "a location"
    )
    or
    // Check line order consistency
    location.getEndLine() < location.getStartLine() and
    issueDesc = "end line before start line" and
    details = "at " + location.toString()
    or
    // Check column order consistency
    location.getEndLine() = location.getStartLine() and
    location.getEndColumn() < location.getStartColumn() and
    issueDesc = "end column before start column" and
    details = "at " + location.toString()
  )
}

// Control flow graph consistency validation
predicate cfg_consistency(string cfgClass, string issueDesc, string details) {
  exists(ControlFlowNode cfgNode | cfgClass = cfgNode.getAQlClass() |
    // Check node mapping uniqueness
    uniqueness_error(count(cfgNode.getNode()), "getNode", issueDesc) and
    details = "at " + cfgNode.getLocation().toString()
    or
    // Validate location existence
    not exists(cfgNode.getLocation()) and
    not exists(Module pkg | pkg.isPackage() | pkg.getEntryNode() = cfgNode or pkg.getAnExitNode() = cfgNode) and
    issueDesc = "no location" and
    details = cfgNode.toString()
    or
    // Check attribute node value uniqueness
    uniqueness_error(count(cfgNode.(AttrNode).getObject()), "getValue", issueDesc) and
    details = "at " + cfgNode.getLocation().toString()
  )
}

// Scope consistency validation
predicate scope_consistency(string scopeClass, string issueDesc, string details) {
  exists(Scope scope | scopeClass = scope.getAQlClass() |
    // Check entry node uniqueness
    uniqueness_error(count(scope.getEntryNode()), "getEntryNode", issueDesc) and
    details = "at " + scope.getLocation().toString()
    or
    // Check toString uniqueness
    uniqueness_error(count(scope.toString()), "toString", issueDesc) and
    details = "at " + scope.getLocation().toString()
    or
    // Check location uniqueness
    uniqueness_error(strictcount(scope.getLocation()), "getLocation", issueDesc) and
    details = "at " + scope.getLocation().toString()
    or
    // Validate location existence
    not exists(scope.getLocation()) and
    issueDesc = "no location" and
    details = scope.toString() and
    not scope.(Module).isPackage()
  )
}

// Helper function to describe built-in objects
string best_description_builtin_object(Object builtinObj) {
  builtinObj.isBuiltin() and
  (
    result = builtinObj.toString()
    or
    not exists(builtinObj.toString()) and py_cobjectnames(builtinObj, result)
    or
    not exists(builtinObj.toString()) and
    not py_cobjectnames(builtinObj, _) and
    result = "builtin object of type " + builtinObj.getAnInferredType().toString()
    or
    not exists(builtinObj.toString()) and
    not py_cobjectnames(builtinObj, _) and
    not exists(builtinObj.getAnInferredType().toString()) and
    result = "builtin object"
  )
}

// Private predicate for introspected built-in objects
private predicate introspected_builtin_object(Object builtinObj) {
  /* Only check objects from the extractor, missing data for objects generated 
   * from C source code analysis is OK as it will be ignored if it doesn't 
   * match up with the introspected form. */
  py_cobject_sources(builtinObj, 0)
}

// Built-in object consistency validation
predicate builtin_object_consistency(string objClass, string issueDesc, string details) {
  exists(Object builtinObj |
    objClass = builtinObj.getAQlClass() and
    details = best_description_builtin_object(builtinObj) and
    introspected_builtin_object(builtinObj)
  |
    // Validate type/name existence
    not exists(builtinObj.getAnInferredType()) and
    not py_cobjectnames(builtinObj, _) and
    issueDesc = "neither name nor type"
    or
    // Check name uniqueness
    uniqueness_error(count(string name | py_cobjectnames(builtinObj, name)), "name", issueDesc)
    or
    not exists(builtinObj.getAnInferredType()) and issueDesc = "no results for getAnInferredType"
    or
    not exists(builtinObj.toString()) and
    issueDesc = "no toString" and
    not exists(string name | name.matches("\\_semmle%") | py_special_objects(builtinObj, name)) and
    not builtinObj = unknownValue()
  )
}

// Source object consistency validation
predicate source_object_consistency(string srcObjClass, string issueDesc, string details) {
  exists(Object srcObj | srcObjClass = srcObj.getAQlClass() and not srcObj.isBuiltin() |
    // Check origin uniqueness
    uniqueness_error(count(srcObj.getOrigin()), "getOrigin", issueDesc) and
    details = "at " + srcObj.getOrigin().getLocation().toString()
    or
    // Validate location existence
    not exists(srcObj.getOrigin().getLocation()) and 
    issueDesc = "no location" and 
    details = "??"
    or
    not exists(srcObj.toString()) and
    issueDesc = "no toString" and
    details = "at " + srcObj.getOrigin().getLocation().toString()
    or
    // Check toString multiplicity
    strictcount(srcObj.toString()) > 1 and 
    issueDesc = "multiple toStrings()" and 
    details = srcObj.toString()
  )
}

// SSA consistency validation
predicate ssa_consistency(string ssaClass, string issueDesc, string details) {
  /* Zero or one definitions of each SSA variable */
  exists(SsaVariable ssaVar | ssaClass = ssaVar.getAQlClass() |
    // Check definition uniqueness
    uniqueness_error(strictcount(ssaVar.getDefinition()), "getDefinition", issueDesc) and
    details = ssaVar.getId()
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
    ssaClass = ssaVar.getAQlClass() and
    issueDesc = "a definition which does not dominate a use at " + useNode.getLocation() and
    details = ssaVar.getId() + " at " + ssaVar.getLocation()
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
    ssaClass = ssaVar.getAQlClass() and
    issueDesc = "a definition which is dominated by the definition of an incoming phi edge" and
    details = ssaVar.getId() + " at " + ssaVar.getLocation()
  )
}

// Function object consistency validation
predicate function_object_consistency(string funcClass, string issueDesc, string details) {
  exists(FunctionObject funcObj | funcClass = funcObj.getAQlClass() |
    details = funcObj.getName() and
    (
      // Validate descriptive string existence
      not exists(funcObj.descriptiveString()) and 
      issueDesc = "no descriptiveString()"
      or
      exists(int cnt | cnt = strictcount(funcObj.descriptiveString()) and cnt > 1 |
        issueDesc = cnt + " descriptiveString()s"
      )
    )
    or
    not exists(funcObj.getName()) and 
    details = "?" and 
    issueDesc = "no name"
  )
}

// Predicate to detect objects with multiple origins
predicate multiple_origins_per_object(Object obj) {
  not obj.isC() and
  not obj instanceof ModuleObject and
  exists(ControlFlowNode useNode, Context ctx |
    strictcount(ControlFlowNode orig | useNode.refersTo(ctx, obj, _, orig)) > 1
  )
}

// Predicate to detect intermediate origins
predicate intermediate_origins(ControlFlowNode useNode, ControlFlowNode interNode, Object obj) {
  exists(ControlFlowNode origNode, Context ctx | not interNode = origNode |
    useNode.refersTo(ctx, obj, _, interNode) and
    interNode.refersTo(ctx, obj, _, origNode) and
    not strictcount(Object val | interNode.(AttrNode).getObject().refersTo(val)) > 1
  )
}

// Points-to consistency validation
predicate points_to_consistency(string nodeClass, string issueDesc, string details) {
  exists(Object obj |
    multiple_origins_per_object(obj) and
    nodeClass = obj.getAQlClass() and
    issueDesc = "multiple origins for an object" and
    details = obj.toString()
  )
  or
  exists(ControlFlowNode useNode, ControlFlowNode interNode |
    intermediate_origins(useNode, interNode, _) and
    nodeClass = useNode.getAQlClass() and
    issueDesc = "has intermediate origin " + interNode and
    details = useNode.toString()
  )
}

// Jump-to-definition consistency validation
predicate jump_to_definition_consistency(string exprClass, string issueDesc, string details) {
  issueDesc = "multiple (jump-to) definitions" and
  exists(Expr expr |
    strictcount(getUniqueDefinition(expr)) > 1 and
    exprClass = expr.getAQlClass() and
    details = expr.toString()
  )
}

// File consistency validation
predicate file_consistency(string fileClass, string issueDesc, string details) {
  exists(File file, Folder folder |
    fileClass = file.getAQlClass() and
    issueDesc = "has same name as a folder" and
    details = file.getAbsolutePath() and
    details = folder.getAbsolutePath()
  )
  or
  exists(Container container |
    fileClass = container.getAQlClass() and
    uniqueness_error(count(container.toString()), "toString", issueDesc) and
    details = "file " + container.getAbsolutePath()
  )
}

// Class value consistency validation
predicate class_value_consistency(string classValClass, string issueDesc, string details) {
  exists(ClassValue classVal, ClassValue superType, string attr |
    details = classVal.getName() and
    superType = classVal.getASuperType() and
    exists(superType.lookup(attr)) and
    not classVal.failedInference(_) and
    not exists(classVal.lookup(attr)) and
    classValClass = classVal.getAQlClass() and
    issueDesc = "no attribute '" + attr + "', but super type '" + superType.getName() + "' does."
  )
}

// Main query combining all consistency checks
from string className, string issueDesc, string details
where
  ast_consistency(className, issueDesc, details) or
  location_consistency(className, issueDesc, details) or
  scope_consistency(className, issueDesc, details) or
  cfg_consistency(className, issueDesc, details) or
  ssa_consistency(className, issueDesc, details) or
  builtin_object_consistency(className, issueDesc, details) or
  source_object_consistency(className, issueDesc, details) or
  function_object_consistency(className, issueDesc, details) or
  points_to_consistency(className, issueDesc, details) or
  jump_to_definition_consistency(className, issueDesc, details) or
  file_consistency(className, issueDesc, details) or
  class_value_consistency(className, issueDesc, details)
select className + " " + details + " has " + issueDesc