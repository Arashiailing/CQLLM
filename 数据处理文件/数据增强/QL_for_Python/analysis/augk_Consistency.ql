/**
 * @name Consistency check
 * @description Comprehensive consistency validation across all code components. Should yield no results when code is consistent.
 * @id py/consistency-check
 */

import python
import analysis.DefinitionTracking

// Validates method result uniqueness for critical operations
predicate uniqueness_error(int resultCount, string methodName, string errorMessage) {
  methodName in [
      "toString", "getLocation", "getNode", "getDefinition", "getEntryNode", "getOrigin",
      "getAnInferredType"
    ] and
  (
    resultCount = 0 and errorMessage = "no results for " + methodName + "()"
    or
    resultCount in [2 .. 10] and errorMessage = resultCount.toString() + " results for " + methodName + "()"
  )
}

// Validates AST node structural integrity
predicate ast_consistency(string className, string errorMessage, string description) {
  exists(AstNode node | className = node.getAQlClass() |
    (
      uniqueness_error(count(node.toString()), "toString", errorMessage) and
      description = "at " + node.getLocation().toString()
    )
    or
    (
      uniqueness_error(strictcount(node.getLocation()), "getLocation", errorMessage) and
      description = node.getLocation().toString()
    )
    or
    (
      not exists(node.getLocation()) and
      not node.(Module).isPackage() and
      errorMessage = "no location" and
      description = node.toString()
    )
  )
}

// Validates location data integrity
predicate location_consistency(string className, string errorMessage, string description) {
  exists(Location loc | className = loc.getAQlClass() |
    (
      uniqueness_error(count(loc.toString()), "toString", errorMessage) and 
      description = "at " + loc.toString()
    )
    or
    (
      not exists(loc.toString()) and
      errorMessage = "no toString" and
      (
        exists(AstNode astNode | astNode.getLocation() = loc |
          description = "a location of a " + astNode.getAQlClass()
        )
        or
        (
          not exists(AstNode astNode | astNode.getLocation() = loc) and
          description = "a location"
        )
      )
    )
    or
    (
      loc.getEndLine() < loc.getStartLine() and
      errorMessage = "end line before start line" and
      description = "at " + loc.toString()
    )
    or
    (
      loc.getEndLine() = loc.getStartLine() and
      loc.getEndColumn() < loc.getStartColumn() and
      errorMessage = "end column before start column" and
      description = "at " + loc.toString()
    )
  )
}

// Validates control flow graph integrity
predicate cfg_consistency(string className, string errorMessage, string description) {
  exists(ControlFlowNode cfgNode | className = cfgNode.getAQlClass() |
    (
      uniqueness_error(count(cfgNode.getNode()), "getNode", errorMessage) and
      description = "at " + cfgNode.getLocation().toString()
    )
    or
    (
      not exists(cfgNode.getLocation()) and
      not exists(Module pkg | pkg.isPackage() | pkg.getEntryNode() = cfgNode or pkg.getAnExitNode() = cfgNode) and
      errorMessage = "no location" and
      description = cfgNode.toString()
    )
    or
    (
      uniqueness_error(count(cfgNode.(AttrNode).getObject()), "getValue", errorMessage) and
      description = "at " + cfgNode.getLocation().toString()
    )
  )
}

// Validates scope data integrity
predicate scope_consistency(string className, string errorMessage, string description) {
  exists(Scope scope | className = scope.getAQlClass() |
    (
      uniqueness_error(count(scope.getEntryNode()), "getEntryNode", errorMessage) and
      description = "at " + scope.getLocation().toString()
    )
    or
    (
      uniqueness_error(count(scope.toString()), "toString", errorMessage) and
      description = "at " + scope.getLocation().toString()
    )
    or
    (
      uniqueness_error(strictcount(scope.getLocation()), "getLocation", errorMessage) and
      description = "at " + scope.getLocation().toString()
    )
    or
    (
      not exists(scope.getLocation()) and
      errorMessage = "no location" and
      description = scope.toString() and
      not scope.(Module).isPackage()
    )
  )
}

// Generates optimal description for built-in objects
string best_description_builtin_object(Object builtinObj) {
  builtinObj.isBuiltin() and
  (
    result = builtinObj.toString()
    or
    not exists(builtinObj.toString()) and py_cobjectnames(builtinObj, result)
    or
    (
      not exists(builtinObj.toString()) and
      not py_cobjectnames(builtinObj, _) and
      result = "builtin object of type " + builtinObj.getAnInferredType().toString()
    )
    or
    (
      not exists(builtinObj.toString()) and
      not py_cobjectnames(builtinObj, _) and
      not exists(builtinObj.getAnInferredType().toString()) and
      result = "builtin object"
    )
  )
}

// Identifies introspected built-in objects (extractor-generated only)
private predicate introspected_builtin_object(Object builtinObj) {
  /* Only check objects from the extractor, missing data for objects generated from C source code analysis is OK
   * as it will be ignored if it doesn't match up with the introspected form. */
  py_cobject_sources(builtinObj, 0)
}

// Validates built-in object consistency
predicate builtin_object_consistency(string className, string errorMessage, string description) {
  exists(Object builtinObj |
    className = builtinObj.getAQlClass() and
    description = best_description_builtin_object(builtinObj) and
    introspected_builtin_object(builtinObj)
  |
    (
      not exists(builtinObj.getAnInferredType()) and
      not py_cobjectnames(builtinObj, _) and
      errorMessage = "neither name nor type"
    )
    or
    uniqueness_error(count(string name | py_cobjectnames(builtinObj, name)), "name", errorMessage)
    or
    not exists(builtinObj.getAnInferredType()) and errorMessage = "no results for getAnInferredType"
    or
    (
      not exists(builtinObj.toString()) and
      errorMessage = "no toString" and
      not exists(string name | name.matches("\\_semmle%") | py_special_objects(builtinObj, name)) and
      not builtinObj = unknownValue()
    )
  )
}

// Validates source object consistency
predicate source_object_consistency(string className, string errorMessage, string description) {
  exists(Object srcObj | className = srcObj.getAQlClass() and not srcObj.isBuiltin() |
    (
      uniqueness_error(count(srcObj.getOrigin()), "getOrigin", errorMessage) and
      description = "at " + srcObj.getOrigin().getLocation().toString()
    )
    or
    (
      not exists(srcObj.getOrigin().getLocation()) and 
      errorMessage = "no location" and 
      description = "??"
    )
    or
    (
      not exists(srcObj.toString()) and
      errorMessage = "no toString" and
      description = "at " + srcObj.getOrigin().getLocation().toString()
    )
    or
    (
      strictcount(srcObj.toString()) > 1 and 
      errorMessage = "multiple toStrings()" and 
      description = srcObj.toString()
    )
  )
}

// Validates SSA form consistency
predicate ssa_consistency(string className, string errorMessage, string description) {
  /* Zero or one definitions of each SSA variable */
  exists(SsaVariable ssaVar | className = ssaVar.getAQlClass() |
    uniqueness_error(strictcount(ssaVar.getDefinition()), "getDefinition", errorMessage) and
    description = ssaVar.getId()
  )
  or
  /* Dominance criterion: Definition *must* dominate *all* uses. */
  exists(SsaVariable ssaVar, ControlFlowNode defNode, ControlFlowNode useNode |
    defNode = ssaVar.getDefinition() and useNode = ssaVar.getAUse()
  |
    not defNode.strictlyDominates(useNode) and
    not defNode = useNode and
    /* Phi nodes which share a flow node with a use come *before* the use */
    not (exists(ssaVar.getAPhiInput()) and defNode = useNode) and
    className = ssaVar.getAQlClass() and
    errorMessage = "a definition which does not dominate a use at " + useNode.getLocation() and
    description = ssaVar.getId() + " at " + ssaVar.getLocation()
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
    className = ssaVar.getAQlClass() and
    errorMessage = " a definition which is dominated by the definition of an incoming phi edge." and
    description = ssaVar.getId() + " at " + ssaVar.getLocation()
  )
}

// Validates function object consistency
predicate function_object_consistency(string className, string errorMessage, string description) {
  exists(FunctionObject funcObj | className = funcObj.getAQlClass() |
    description = funcObj.getName() and
    (
      not exists(funcObj.descriptiveString()) and errorMessage = "no descriptiveString()"
      or
      exists(int cnt | cnt = strictcount(funcObj.descriptiveString()) and cnt > 1 |
        errorMessage = cnt + "descriptiveString()s"
      )
    )
    or
    (
      not exists(funcObj.getName()) and 
      description = "?" and 
      errorMessage = "no name"
    )
  )
}

// Identifies objects with multiple origins
predicate multiple_origins_per_object(Object obj) {
  not obj.isC() and
  not obj instanceof ModuleObject and
  exists(ControlFlowNode useNode, Context ctx |
    strictcount(ControlFlowNode orig | useNode.refersTo(ctx, obj, _, orig)) > 1
  )
}

// Identifies intermediate origin nodes
predicate intermediate_origins(ControlFlowNode useNode, ControlFlowNode interNode, Object obj) {
  exists(ControlFlowNode origNode, Context ctx | not interNode = origNode |
    useNode.refersTo(ctx, obj, _, interNode) and
    interNode.refersTo(ctx, obj, _, origNode) and
    /* It can sometimes happen that two different modules (e.g. cPickle and Pickle)
     * have the same attribute, but different origins. */
    not strictcount(Object val | interNode.(AttrNode).getObject().refersTo(val)) > 1
  )
}

// Validates points-to analysis consistency
predicate points_to_consistency(string className, string errorMessage, string description) {
  exists(Object obj |
    multiple_origins_per_object(obj) and
    className = obj.getAQlClass() and
    errorMessage = "multiple origins for an object" and
    description = obj.toString()
  )
  or
  exists(ControlFlowNode useNode, ControlFlowNode interNode |
    intermediate_origins(useNode, interNode, _) and
    className = useNode.getAQlClass() and
    errorMessage = "has intermediate origin " + interNode and
    description = useNode.toString()
  )
}

// Validates jump-to-definition consistency
predicate jump_to_definition_consistency(string className, string errorMessage, string description) {
  errorMessage = "multiple (jump-to) definitions" and
  exists(Expr expr |
    strictcount(getUniqueDefinition(expr)) > 1 and
    className = expr.getAQlClass() and
    description = expr.toString()
  )
}

// Validates file system consistency
predicate file_consistency(string className, string errorMessage, string description) {
  exists(File file, Folder folder |
    className = file.getAQlClass() and
    errorMessage = "has same name as a folder" and
    description = file.getAbsolutePath() and
    description = folder.getAbsolutePath()
  )
  or
  exists(Container container |
    className = container.getAQlClass() and
    uniqueness_error(count(container.toString()), "toString", errorMessage) and
    description = "file " + container.getAbsolutePath()
  )
}

// Validates class inheritance consistency
predicate class_value_consistency(string className, string errorMessage, string description) {
  exists(ClassValue classVal, ClassValue superClass, string attrName |
    description = classVal.getName() and
    superClass = classVal.getASuperType() and
    exists(superClass.lookup(attrName)) and
    not classVal.failedInference(_) and
    not exists(classVal.lookup(attrName)) and
    className = classVal.getAQlClass() and
    errorMessage = "no attribute '" + attrName + "', but super type '" + superClass.getName() + "' does."
  )
}

// Aggregate all consistency checks
from string className, string errorMessage, string description
where
  ast_consistency(className, errorMessage, description) or
  location_consistency(className, errorMessage, description) or
  scope_consistency(className, errorMessage, description) or
  cfg_consistency(className, errorMessage, description) or
  ssa_consistency(className, errorMessage, description) or
  builtin_object_consistency(className, errorMessage, description) or
  source_object_consistency(className, errorMessage, description) or
  function_object_consistency(className, errorMessage, description) or
  points_to_consistency(className, errorMessage, description) or
  jump_to_definition_consistency(className, errorMessage, description) or
  file_consistency(className, errorMessage, description) or
  class_value_consistency(className, errorMessage, description)
select className + " " + description + " has " + errorMessage