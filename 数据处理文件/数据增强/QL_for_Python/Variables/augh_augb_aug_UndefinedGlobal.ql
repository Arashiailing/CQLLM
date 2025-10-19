/**
 * @name Use of an undefined global variable
 * @description Detects usage of global variables before they are initialized, which can cause runtime exceptions.
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

// Determines if a variable access is protected against NameError exceptions
// by specific error handling mechanisms
predicate is_name_error_guarded(Name variableAccess) {
  // Protection via try-except block catching NameError
  exists(Try tryBlock | tryBlock.getBody().getAnItem().contains(variableAccess) |
    tryBlock.getAHandler().getType().(Name).getId() = "NameError"
  )
  or
  // Protection via conditional block controlling globals() check
  exists(ConditionBlock guardCondition, BasicBlock dependentBlock, Call globalsCall |
    guardCondition.getLastNode().getNode().contains(globalsCall) or
    guardCondition.getLastNode().getNode() = globalsCall
  |
    globalsCall.getFunc().(Name).getId() = "globals" and
    guardCondition.controls(dependentBlock, _) and
    dependentBlock.contains(variableAccess.getAFlowNode())
  )
}

// Check if module contains unresolved star imports that could potentially define the variable
predicate has_unresolved_star_import(Module mod) {
  exists(ImportStar starImport | starImport.getScope() = mod |
    exists(ModuleValue sourceModule | 
      sourceModule.importedAs(starImport.getImportedModuleName()) and
      not sourceModule.hasCompleteExportInfo()
    )
  )
}

// Helper predicate to check if a name is defined at module level or in builtins
private predicate is_module_level_or_builtin_defined(Name variableAccess) {
  variableAccess.getEnclosingModule().(ImportTimeScope).definesName(variableAccess.getId()) or
  exists(ModuleValue moduleEntity | moduleEntity.getScope() = variableAccess.getEnclosingModule() | 
    moduleEntity.hasAttribute(variableAccess.getId())) or
  globallyDefinedName(variableAccess.getId()) or
  (variableAccess.getEnclosingModule().isPackageInit() and variableAccess.getId() = "__path__")
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
      not exists(Assign varAssignment, Scope definitionScope |
        varAssignment.getATarget() = globalVar.getAnAccess() and varAssignment.getScope() = definitionScope
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
  not is_module_level_or_builtin_defined(variableAccess) and
  not exists(SsaVariable ssaVariable | ssaVariable.getAUse().getNode() = variableAccess and 
    not ssaVariable.maybeUndefined()) and
  not is_name_error_guarded(variableAccess)
}

// Check for undefined global usage within class/module scope
predicate is_undefined_in_class_or_module(Name variableAccess) {
  exists(GlobalVariable globalVar | variableAccess.uses(globalVar)) and
  not variableAccess.getScope().getScope*() instanceof Function and
  exists(SsaVariable ssaVariable | ssaVariable.getAUse().getNode() = variableAccess and 
    ssaVariable.maybeUndefined()) and
  not is_name_error_guarded(variableAccess) and
  not is_module_level_or_builtin_defined(variableAccess)
}

// Check if module uses dynamic execution functions that could define variables
predicate uses_dynamic_execution(Module mod) {
  exists(Exec execStatement | execStatement.getScope() = mod)
  or
  exists(CallNode dynamicCall, FunctionValue execFunction | 
    execFunction.getACall() = dynamicCall and dynamicCall.getScope() = mod and
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

// Check for first occurrence of a variable usage in a basic block
private predicate is_first_usage_in_block(Name varAccess) {
  exists(GlobalVariable globalVar, BasicBlock basicBlock, int nodeIndex |
    nodeIndex = min(int index | basicBlock.getNode(index).getNode() = globalVar.getALoad()) and 
    basicBlock.getNode(nodeIndex) = varAccess.getAFlowNode()
  )
}

// Identify first undefined usage in control flow
predicate is_first_undefined_usage(Name varAccess) {
  is_undefined_global_usage(varAccess) and
  exists(GlobalVariable globalVar | globalVar.getALoad() = varAccess |
    is_first_usage_in_block(varAccess) and
    not exists(ControlFlowNode priorNode |
      priorNode.getNode() = globalVar.getALoad() and
      priorNode.getBasicBlock().strictlyDominates(varAccess.getAFlowNode().getBasicBlock())
    )
  )
}

// Query: Find first undefined global variable usages
from Name variableAccess
where is_first_undefined_usage(variableAccess)
select variableAccess, "This use of global variable '" + variableAccess.getId() + "' may be undefined."