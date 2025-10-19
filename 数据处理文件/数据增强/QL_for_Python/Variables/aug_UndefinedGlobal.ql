/**
 * @name Use of an undefined global variable
 * @description Using a global variable before it is initialized causes an exception.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision low
 * @id py/undefined-global-variable
 */

import python
import Variables.MonkeyPatched
import semmle.python.pointsto.PointsTo

// Check if variable usage is protected by NameError handling
predicate is_name_error_guarded(Name variableAccess) {
  // Protection via try-except block catching NameError
  exists(Try tryBlock | tryBlock.getBody().getAnItem().contains(variableAccess) |
    tryBlock.getAHandler().getType().(Name).getId() = "NameError"
  )
  or
  // Protection via conditional block controlling globals() check
  exists(ConditionBlock guardBlock, BasicBlock controlledBlock, Call globalsCall |
    guardBlock.getLastNode().getNode().contains(globalsCall) or
    guardBlock.getLastNode().getNode() = globalsCall
  |
    globalsCall.getFunc().(Name).getId() = "globals" and
    guardBlock.controls(controlledBlock, _) and
    controlledBlock.contains(variableAccess.getAFlowNode())
  )
}

// Check if module contains unresolved star imports
predicate has_unresolved_star_import(Module mod) {
  exists(ImportStar starImport | starImport.getScope() = mod |
    exists(ModuleValue importedModule | 
      importedModule.importedAs(starImport.getImportedModuleName()) and
      not importedModule.hasCompleteExportInfo()
    )
  )
}

// Check for undefined global usage within function scope
predicate is_undefined_in_function_context(Name variableAccess) {
  exists(Function enclosingFunction |
    variableAccess.getScope().getScope*() = enclosingFunction and
    // Verify function is method/nested or module-initialized
    (
      not enclosingFunction.getScope() = variableAccess.getEnclosingModule() or
      variableAccess.getEnclosingModule().(ImportTimeScope).definesName(enclosingFunction.getName())
    ) and
    // Identify undefined global variable
    exists(GlobalVariable globalVar | variableAccess.uses(globalVar) |
      not exists(Assign assignment, Scope definitionScope |
        assignment.getATarget() = globalVar.getAnAccess() and assignment.getScope() = definitionScope
      |
        definitionScope = enclosingFunction
        or
        // Exclude modules (handled separately)
        (definitionScope = enclosingFunction.getScope().getScope*() and 
         not definitionScope instanceof Module)
      )
    )
  ) and
  // Ensure no module-level definition
  not variableAccess.getEnclosingModule().(ImportTimeScope).definesName(variableAccess.getId()) and
  not exists(ModuleValue moduleVal | moduleVal.getScope() = variableAccess.getEnclosingModule() | 
    moduleVal.hasAttribute(variableAccess.getId())) and
  not globallyDefinedName(variableAccess.getId()) and
  not exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = variableAccess and 
    not ssaVar.maybeUndefined()) and
  not is_name_error_guarded(variableAccess) and
  not (variableAccess.getEnclosingModule().isPackageInit() and variableAccess.getId() = "__path__")
}

// Check for undefined global usage within class/module scope
predicate is_undefined_in_class_or_module(Name variableAccess) {
  exists(GlobalVariable globalVar | variableAccess.uses(globalVar)) and
  not variableAccess.getScope().getScope*() instanceof Function and
  exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = variableAccess and 
    ssaVar.maybeUndefined()) and
  not is_name_error_guarded(variableAccess) and
  not exists(ModuleValue moduleVal | moduleVal.getScope() = variableAccess.getEnclosingModule() | 
    moduleVal.hasAttribute(variableAccess.getId())) and
  not (variableAccess.getEnclosingModule().isPackageInit() and variableAccess.getId() = "__path__") and
  not globallyDefinedName(variableAccess.getId())
}

// Check if module uses dynamic exec() functions
predicate uses_dynamic_execution(Module mod) {
  exists(Exec execStatement | execStatement.getScope() = mod)
  or
  exists(CallNode callNode, FunctionValue execFunction | 
    execFunction.getACall() = callNode and callNode.getScope() = mod and
    (execFunction.getName() = "exec" or execFunction.getName() = "execfile")
  )
}

// Main predicate for undefined global variable usage
predicate is_undefined_global_usage(Name variableAccess) {
  // Combine context checks with exclusions
  (
    is_undefined_in_class_or_module(variableAccess)
    or
    is_undefined_in_function_context(variableAccess)
  ) and
  // Apply exclusions
  not monkey_patched_builtin(variableAccess.getId()) and
  not has_unresolved_star_import(variableAccess.getEnclosingModule()) and
  not uses_dynamic_execution(variableAccess.getEnclosingModule()) and
  not exists(variableAccess.getVariable().getAStore()) and
  not variableAccess.pointsTo(_)
}

// Check for first occurrence in a basic block
private predicate is_first_usage_in_block(Name variableUsage) {
  exists(GlobalVariable globalVar, BasicBlock block, int nodeIndex |
    nodeIndex = min(int index | block.getNode(index).getNode() = globalVar.getALoad()) and 
    block.getNode(nodeIndex) = variableUsage.getAFlowNode()
  )
}

// Identify first undefined usage in control flow
predicate is_first_undefined_usage(Name variableUsage) {
  is_undefined_global_usage(variableUsage) and
  exists(GlobalVariable globalVar | globalVar.getALoad() = variableUsage |
    is_first_usage_in_block(variableUsage) and
    not exists(ControlFlowNode otherNode |
      otherNode.getNode() = globalVar.getALoad() and
      otherNode.getBasicBlock().strictlyDominates(variableUsage.getAFlowNode().getBasicBlock())
    )
  )
}

// Query: Find first undefined global variable usages
from Name variableAccess
where is_first_undefined_usage(variableAccess)
select variableAccess, "This use of global variable '" + variableAccess.getId() + "' may be undefined."