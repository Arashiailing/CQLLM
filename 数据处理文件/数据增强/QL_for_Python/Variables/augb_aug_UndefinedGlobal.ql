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

// Determine if a variable access is protected against NameError exceptions
// by specific error handling mechanisms
predicate is_name_error_guarded(Name variableUsage) {
  // Protection via try-except block catching NameError
  exists(Try tryStmt | tryStmt.getBody().getAnItem().contains(variableUsage) |
    tryStmt.getAHandler().getType().(Name).getId() = "NameError"
  )
  or
  // Protection via conditional block controlling globals() check
  exists(ConditionBlock guardCondition, BasicBlock dependentBlock, Call globalsInvocation |
    guardCondition.getLastNode().getNode().contains(globalsInvocation) or
    guardCondition.getLastNode().getNode() = globalsInvocation
  |
    globalsInvocation.getFunc().(Name).getId() = "globals" and
    guardCondition.controls(dependentBlock, _) and
    dependentBlock.contains(variableUsage.getAFlowNode())
  )
}

// Check if module contains unresolved star imports that could potentially define the variable
predicate has_unresolved_star_import(Module mod) {
  exists(ImportStar starImportStmt | starImportStmt.getScope() = mod |
    exists(ModuleValue sourceModule | 
      sourceModule.importedAs(starImportStmt.getImportedModuleName()) and
      not sourceModule.hasCompleteExportInfo()
    )
  )
}

// Helper predicate to check if a name is defined at module level or in builtins
private predicate is_module_level_or_builtin_defined(Name variableUsage) {
  variableUsage.getEnclosingModule().(ImportTimeScope).definesName(variableUsage.getId()) or
  exists(ModuleValue moduleEntity | moduleEntity.getScope() = variableUsage.getEnclosingModule() | 
    moduleEntity.hasAttribute(variableUsage.getId())) or
  globallyDefinedName(variableUsage.getId()) or
  (variableUsage.getEnclosingModule().isPackageInit() and variableUsage.getId() = "__path__")
}

// Check for undefined global usage within function scope
predicate is_undefined_in_function_context(Name variableUsage) {
  exists(Function containerFunction |
    variableUsage.getScope().getScope*() = containerFunction and
    // Verify function is method/nested or module-initialized
    (
      not containerFunction.getScope() = variableUsage.getEnclosingModule() or
      variableUsage.getEnclosingModule().(ImportTimeScope).definesName(containerFunction.getName())
    ) and
    // Identify undefined global variable
    exists(GlobalVariable globalVariable | variableUsage.uses(globalVariable) |
      not exists(Assign assignment, Scope definingScope |
        assignment.getATarget() = globalVariable.getAnAccess() and assignment.getScope() = definingScope
      |
        definingScope = containerFunction
        or
        // Exclude modules (handled separately)
        (definingScope = containerFunction.getScope().getScope*() and 
         not definingScope instanceof Module)
      )
    )
  ) and
  // Ensure no module-level definition
  not is_module_level_or_builtin_defined(variableUsage) and
  not exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = variableUsage and 
    not ssaVar.maybeUndefined()) and
  not is_name_error_guarded(variableUsage)
}

// Check for undefined global usage within class/module scope
predicate is_undefined_in_class_or_module(Name variableUsage) {
  exists(GlobalVariable globalVariable | variableUsage.uses(globalVariable)) and
  not variableUsage.getScope().getScope*() instanceof Function and
  exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = variableUsage and 
    ssaVar.maybeUndefined()) and
  not is_name_error_guarded(variableUsage) and
  not is_module_level_or_builtin_defined(variableUsage)
}

// Check if module uses dynamic execution functions that could define variables
predicate uses_dynamic_execution(Module mod) {
  exists(Exec execStmt | execStmt.getScope() = mod)
  or
  exists(CallNode functionCall, FunctionValue execFuncValue | 
    execFuncValue.getACall() = functionCall and functionCall.getScope() = mod and
    (execFuncValue.getName() = "exec" or execFuncValue.getName() = "execfile")
  )
}

// Main predicate for undefined global variable usage
predicate is_undefined_global_usage(Name variableUsage) {
  // Combine context checks with exclusions
  (
    is_undefined_in_class_or_module(variableUsage)
    or
    is_undefined_in_function_context(variableUsage)
  ) and
  // Apply exclusions
  not monkey_patched_builtin(variableUsage.getId()) and
  not has_unresolved_star_import(variableUsage.getEnclosingModule()) and
  not uses_dynamic_execution(variableUsage.getEnclosingModule()) and
  not exists(variableUsage.getVariable().getAStore()) and
  not variableUsage.pointsTo(_)
}

// Check for first occurrence of a variable usage in a basic block
private predicate is_first_usage_in_block(Name varUsage) {
  exists(GlobalVariable globalVariable, BasicBlock codeBlock, int positionIndex |
    positionIndex = min(int index | codeBlock.getNode(index).getNode() = globalVariable.getALoad()) and 
    codeBlock.getNode(positionIndex) = varUsage.getAFlowNode()
  )
}

// Identify first undefined usage in control flow
predicate is_first_undefined_usage(Name varUsage) {
  is_undefined_global_usage(varUsage) and
  exists(GlobalVariable globalVariable | globalVariable.getALoad() = varUsage |
    is_first_usage_in_block(varUsage) and
    not exists(ControlFlowNode precedingNode |
      precedingNode.getNode() = globalVariable.getALoad() and
      precedingNode.getBasicBlock().strictlyDominates(varUsage.getAFlowNode().getBasicBlock())
    )
  )
}

// Query: Find first undefined global variable usages
from Name variableAccess
where is_first_undefined_usage(variableAccess)
select variableAccess, "This use of global variable '" + variableAccess.getId() + "' may be undefined."