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

// Determines if a variable access is protected by NameError exception handling
predicate is_name_error_guarded(Name variableUsage) {
  // Case 1: Protected by try-except block catching NameError
  exists(Try tryStmt | tryStmt.getBody().getAnItem().contains(variableUsage) |
    tryStmt.getAHandler().getType().(Name).getId() = "NameError"
  )
  or
  // Case 2: Protected by conditional block with globals() check
  exists(ConditionBlock guardCondition, BasicBlock dependentBlock, Call globalsInvocation |
    guardCondition.getLastNode().getNode().contains(globalsInvocation) or
    guardCondition.getLastNode().getNode() = globalsInvocation
  |
    globalsInvocation.getFunc().(Name).getId() = "globals" and
    guardCondition.controls(dependentBlock, _) and
    dependentBlock.contains(variableUsage.getAFlowNode())
  )
}

// Checks if a module contains unresolved star imports (from module import *)
predicate has_unresolved_star_import(Module mod) {
  exists(ImportStar starImportStmt | starImportStmt.getScope() = mod |
    exists(ModuleValue sourceModule | 
      sourceModule.importedAs(starImportStmt.getImportedModuleName()) and
      not sourceModule.hasCompleteExportInfo()
    )
  )
}

// Verifies if a global variable usage is undefined within a function context
predicate is_undefined_in_function_context(Name variableUsage) {
  exists(Function containingFunction |
    variableUsage.getScope().getScope*() = containingFunction and
    // Ensure function is either a method/nested function or module-initialized
    (
      not containingFunction.getScope() = variableUsage.getEnclosingModule() or
      variableUsage.getEnclosingModule().(ImportTimeScope).definesName(containingFunction.getName())
    ) and
    // Identify undefined global variable
    exists(GlobalVariable globalVariable | variableUsage.uses(globalVariable) |
      not exists(Assign valueAssignment, Scope varDefinitionScope |
        valueAssignment.getATarget() = globalVariable.getAnAccess() and valueAssignment.getScope() = varDefinitionScope
      |
        varDefinitionScope = containingFunction
        or
        // Exclude module-level definitions (handled separately)
        (varDefinitionScope = containingFunction.getScope().getScope*() and 
         not varDefinitionScope instanceof Module)
      )
    )
  ) and
  // Common checks for undefined global variables
  // Ensure no module-level definition exists
  not variableUsage.getEnclosingModule().(ImportTimeScope).definesName(variableUsage.getId()) and
  not exists(ModuleValue moduleEntity | moduleEntity.getScope() = variableUsage.getEnclosingModule() | 
    moduleEntity.hasAttribute(variableUsage.getId())) and
  not globallyDefinedName(variableUsage.getId()) and
  not is_name_error_guarded(variableUsage) and
  not (variableUsage.getEnclosingModule().isPackageInit() and variableUsage.getId() = "__path__") and
  not exists(SsaVariable ssaVariable | ssaVariable.getAUse().getNode() = variableUsage and 
    not ssaVariable.maybeUndefined())
}

// Verifies if a global variable usage is undefined within a class or module context
predicate is_undefined_in_class_or_module(Name variableUsage) {
  exists(GlobalVariable globalVariable | variableUsage.uses(globalVariable)) and
  not variableUsage.getScope().getScope*() instanceof Function and
  exists(SsaVariable ssaVariable | ssaVariable.getAUse().getNode() = variableUsage and 
    ssaVariable.maybeUndefined()) and
  // Common checks for undefined global variables
  // Ensure no module-level definition exists
  not variableUsage.getEnclosingModule().(ImportTimeScope).definesName(variableUsage.getId()) and
  not exists(ModuleValue moduleEntity | moduleEntity.getScope() = variableUsage.getEnclosingModule() | 
    moduleEntity.hasAttribute(variableUsage.getId())) and
  not globallyDefinedName(variableUsage.getId()) and
  not is_name_error_guarded(variableUsage) and
  not (variableUsage.getEnclosingModule().isPackageInit() and variableUsage.getId() = "__path__")
}

// Determines if a module uses dynamic execution functions (exec/execfile)
predicate uses_dynamic_execution(Module mod) {
  exists(Exec execStmt | execStmt.getScope() = mod)
  or
  exists(CallNode functionCall, FunctionValue execFunctionValue | 
    execFunctionValue.getACall() = functionCall and functionCall.getScope() = mod and
    (execFunctionValue.getName() = "exec" or execFunctionValue.getName() = "execfile")
  )
}

// Main predicate to identify undefined global variable usage
predicate is_undefined_global_usage(Name variableUsage) {
  // Combine context-specific checks
  (
    is_undefined_in_class_or_module(variableUsage)
    or
    is_undefined_in_function_context(variableUsage)
  ) and
  // Apply exclusion criteria
  not monkey_patched_builtin(variableUsage.getId()) and
  not has_unresolved_star_import(variableUsage.getEnclosingModule()) and
  not uses_dynamic_execution(variableUsage.getEnclosingModule()) and
  not exists(variableUsage.getVariable().getAStore()) and
  not variableUsage.pointsTo(_)
}

// Identifies if a variable usage is the first occurrence within its basic block
private predicate is_first_usage_in_block(Name variableUsage) {
  exists(GlobalVariable globalVariable, BasicBlock codeBlock, int positionIndex |
    positionIndex = min(int index | codeBlock.getNode(index).getNode() = globalVariable.getALoad()) and 
    codeBlock.getNode(positionIndex) = variableUsage.getAFlowNode()
  )
}

// Identifies the first undefined usage of a global variable in the control flow
predicate is_first_undefined_usage(Name variableUsage) {
  is_undefined_global_usage(variableUsage) and
  exists(GlobalVariable globalVariable | globalVariable.getALoad() = variableUsage |
    is_first_usage_in_block(variableUsage) and
    not exists(ControlFlowNode precedingNode |
      precedingNode.getNode() = globalVariable.getALoad() and
      precedingNode.getBasicBlock().strictlyDominates(variableUsage.getAFlowNode().getBasicBlock())
    )
  )
}

// Query: Find first undefined global variable usages
from Name variableUsage
where is_first_undefined_usage(variableUsage)
select variableUsage, "This use of global variable '" + variableUsage.getId() + "' may be undefined."