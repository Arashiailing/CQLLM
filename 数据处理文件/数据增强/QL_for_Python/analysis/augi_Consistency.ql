/**
 * @name Consistency check
 * @description Comprehensive consistency validation for Python code analysis. Should never produce results.
 * @id py/consistency-check
 */

import python
import analysis.DefinitionTracking

// Validates uniqueness constraints for analysis methods
predicate uniqueness_error(int countValue, string methodName, string errorMsg) {
  methodName in [
      "toString", "getLocation", "getNode", "getDefinition", "getEntryNode", "getOrigin",
      "getAnInferredType"
    ] and
  (
    countValue = 0 and errorMsg = "no results for " + methodName + "()"
    or
    countValue in [2 .. 10] and errorMsg = countValue.toString() + " results for " + methodName + "()"
  )
}

// Validates AST node integrity and method consistency
predicate ast_consistency(string className, string issue, string details) {
  exists(AstNode node | className = node.getAQlClass() |
    uniqueness_error(count(node.toString()), "toString", issue) and
    details = "at " + node.getLocation().toString()
    or
    uniqueness_error(strictcount(node.getLocation()), "getLocation", issue) and
    details = node.getLocation().toString()
    or
    not exists(node.getLocation()) and
    not node.(Module).isPackage() and
    issue = "no location" and
    details = node.toString()
  )
}

// Validates location object properties and relationships
predicate location_consistency(string className, string issue, string details) {
  exists(Location loc | className = loc.getAQlClass() |
    uniqueness_error(count(loc.toString()), "toString", issue) and 
    details = "at " + loc.toString()
    or
    not exists(loc.toString()) and
    issue = "no toString" and
    (
      exists(AstNode element | element.getLocation() = loc |
        details = "a location of a " + element.getAQlClass()
      )
      or
      not exists(AstNode element | element.getLocation() = loc) and
      details = "a location"
    )
    or
    loc.getEndLine() < loc.getStartLine() and
    issue = "end line before start line" and
    details = "at " + loc.toString()
    or
    loc.getEndLine() = loc.getStartLine() and
    loc.getEndColumn() < loc.getStartColumn() and
    issue = "end column before start column" and
    details = "at " + loc.toString()
  )
}

// Validates control flow graph node properties
predicate cfg_consistency(string className, string issue, string details) {
  exists(ControlFlowNode cfgNode | className = cfgNode.getAQlClass() |
    uniqueness_error(count(cfgNode.getNode()), "getNode", issue) and
    details = "at " + cfgNode.getLocation().toString()
    or
    not exists(cfgNode.getLocation()) and
    not exists(Module pkg | pkg.isPackage() | pkg.getEntryNode() = cfgNode or pkg.getAnExitNode() = cfgNode) and
    issue = "no location" and
    details = cfgNode.toString()
    or
    uniqueness_error(count(cfgNode.(AttrNode).getObject()), "getValue", issue) and
    details = "at " + cfgNode.getLocation().toString()
  )
}

// Validates scope object properties and relationships
predicate scope_consistency(string className, string issue, string details) {
  exists(Scope scope | className = scope.getAQlClass() |
    uniqueness_error(count(scope.getEntryNode()), "getEntryNode", issue) and
    details = "at " + scope.getLocation().toString()
    or
    uniqueness_error(count(scope.toString()), "toString", issue) and
    details = "at " + scope.getLocation().toString()
    or
    uniqueness_error(strictcount(scope.getLocation()), "getLocation", issue) and
    details = "at " + scope.getLocation().toString()
    or
    not exists(scope.getLocation()) and
    issue = "no location" and
    details = scope.toString() and
    not scope.(Module).isPackage()
  )
}

// Generates descriptive string for built-in objects
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

// Identifies introspected built-in objects for analysis
private predicate introspected_builtin_object(Object builtinObj) {
  /* Only check objects from the extractor, missing data for objects generated from C source code analysis is OK */
  py_cobject_sources(builtinObj, 0)
}

// Validates built-in object properties and relationships
predicate builtin_object_consistency(string className, string issue, string details) {
  exists(Object builtinObj |
    className = builtinObj.getAQlClass() and
    details = best_description_builtin_object(builtinObj) and
    introspected_builtin_object(builtinObj)
  |
    not exists(builtinObj.getAnInferredType()) and
    not py_cobjectnames(builtinObj, _) and
    issue = "neither name nor type"
    or
    uniqueness_error(count(string name | py_cobjectnames(builtinObj, name)), "name", issue)
    or
    not exists(builtinObj.getAnInferredType()) and issue = "no results for getAnInferredType"
    or
    not exists(builtinObj.toString()) and
    issue = "no toString" and
    not exists(string name | name.matches("\\_semmle%") | py_special_objects(builtinObj, name)) and
    not builtinObj = unknownValue()
  )
}

// Validates source object properties and relationships
predicate source_object_consistency(string className, string issue, string details) {
  exists(Object srcObj | className = srcObj.getAQlClass() and not srcObj.isBuiltin() |
    uniqueness_error(count(srcObj.getOrigin()), "getOrigin", issue) and
    details = "at " + srcObj.getOrigin().getLocation().toString()
    or
    not exists(srcObj.getOrigin().getLocation()) and 
    issue = "no location" and 
    details = "??"
    or
    not exists(srcObj.toString()) and
    issue = "no toString" and
    details = "at " + srcObj.getOrigin().getLocation().toString()
    or
    strictcount(srcObj.toString()) > 1 and 
    issue = "multiple toStrings()" and 
    details = srcObj.toString()
  )
}

// Validates SSA variable properties and dominance relationships
predicate ssa_consistency(string className, string issue, string details) {
  /* Zero or one definitions of each SSA variable */
  exists(SsaVariable ssaVar | className = ssaVar.getAQlClass() |
    uniqueness_error(strictcount(ssaVar.getDefinition()), "getDefinition", issue) and
    details = ssaVar.getId()
  )
  or
  /* Dominance criterion: Definition *must* dominate *all* uses */
  exists(SsaVariable ssaVar, ControlFlowNode defNode, ControlFlowNode useNode |
    defNode = ssaVar.getDefinition() and useNode = ssaVar.getAUse()
  |
    not defNode.strictlyDominates(useNode) and
    not defNode = useNode and
    /* Phi nodes which share a flow node with a use come *before* the use */
    not (exists(ssaVar.getAPhiInput()) and defNode = useNode) and
    className = ssaVar.getAQlClass() and
    issue = "a definition which does not dominate a use at " + useNode.getLocation() and
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
    className = ssaVar.getAQlClass() and
    issue = " a definition which is dominated by the definition of an incoming phi edge." and
    details = ssaVar.getId() + " at " + ssaVar.getLocation()
  )
}

// Validates function object properties and naming
predicate function_object_consistency(string className, string issue, string details) {
  exists(FunctionObject funcObj | className = funcObj.getAQlClass() |
    details = funcObj.getName() and
    (
      not exists(funcObj.descriptiveString()) and issue = "no descriptiveString()"
      or
      exists(int cnt | cnt = strictcount(funcObj.descriptiveString()) and cnt > 1 |
        issue = cnt + "descriptiveString()s"
      )
    )
    or
    not exists(funcObj.getName()) and details = "?" and issue = "no name"
  )
}

// Identifies objects with multiple origin references
predicate multiple_origins_per_object(Object obj) {
  not obj.isC() and
  not obj instanceof ModuleObject and
  exists(ControlFlowNode use, Context ctx |
    strictcount(ControlFlowNode orig | use.refersTo(ctx, obj, _, orig)) > 1
  )
}

// Identifies intermediate origin references in object flow
predicate intermediate_origins(ControlFlowNode use, ControlFlowNode inter, Object obj) {
  exists(ControlFlowNode orig, Context ctx | not inter = orig |
    use.refersTo(ctx, obj, _, inter) and
    inter.refersTo(ctx, obj, _, orig) and
    /* Handle cases where different modules have same attribute but different origins */
    not strictcount(Object val | inter.(AttrNode).getObject().refersTo(val)) > 1
  )
}

// Validates object reference consistency and origin tracking
predicate points_to_consistency(string className, string issue, string details) {
  exists(Object obj |
    multiple_origins_per_object(obj) and
    className = obj.getAQlClass() and
    issue = "multiple origins for an object" and
    details = obj.toString()
  )
  or
  exists(ControlFlowNode use, ControlFlowNode inter |
    intermediate_origins(use, inter, _) and
    className = use.getAQlClass() and
    issue = "has intermediate origin " + inter and
    details = use.toString()
  )
}

// Validates jump-to-definition uniqueness
predicate jump_to_definition_consistency(string className, string issue, string details) {
  issue = "multiple (jump-to) definitions" and
  exists(Expr expr |
    strictcount(getUniqueDefinition(expr)) > 1 and
    className = expr.getAQlClass() and
    details = expr.toString()
  )
}

// Validates file and container properties
predicate file_consistency(string className, string issue, string details) {
  exists(File file, Folder folder |
    className = file.getAQlClass() and
    issue = "has same name as a folder" and
    details = file.getAbsolutePath() and
    details = folder.getAbsolutePath()
  )
  or
  exists(Container container |
    className = container.getAQlClass() and
    uniqueness_error(count(container.toString()), "toString", issue) and
    details = "file " + container.getAbsolutePath()
  )
}

// Validates class inheritance and attribute resolution
predicate class_value_consistency(string className, string issue, string details) {
  exists(ClassValue classVal, ClassValue superType, string attrName |
    details = classVal.getName() and
    superType = classVal.getASuperType() and
    exists(superType.lookup(attrName)) and
    not classVal.failedInference(_) and
    not exists(classVal.lookup(attrName)) and
    className = classVal.getAQlClass() and
    issue = "no attribute '" + attrName + "', but super type '" + superType.getName() + "' does."
  )
}

// Consolidated consistency validation across all analysis domains
from string className, string issue, string details
where
  ast_consistency(className, issue, details) or
  location_consistency(className, issue, details) or
  scope_consistency(className, issue, details) or
  cfg_consistency(className, issue, details) or
  ssa_consistency(className, issue, details) or
  builtin_object_consistency(className, issue, details) or
  source_object_consistency(className, issue, details) or
  function_object_consistency(className, issue, details) or
  points_to_consistency(className, issue, details) or
  jump_to_definition_consistency(className, issue, details) or
  file_consistency(className, issue, details) or
  class_value_consistency(className, issue, details)
select className + " " + details + " has " + issue