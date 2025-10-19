/**
 * @name Explicit export is not defined
 * @description An undefined attribute is included in `__all__`, which will cause an exception 
 *              when the module is imported using the `from ... import *` syntax.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/undefined-export
 */

import python

/** 
 * Holds if the given name is declared in the module's `__all__` list.
 * @param targetModule The module to check.
 * @param exportNameLiteral The string literal representing the name.
 * @returns true if the name is present in the `__all__` list.
 */
predicate declaredInAll(Module targetModule, StringLiteral exportNameLiteral) {
  exists(Assign assignStmt, GlobalVariable allVar |
    assignStmt.defines(allVar) and // Locate assignment defining __all__
    assignStmt.getScope() = targetModule and // Ensure assignment is in target module
    allVar.getId() = "__all__" and // Verify variable name is __all__
    assignStmt.getValue().(List).getAnElt() = exportNameLiteral // Check name in list
  )
}

/**
 * Holds if the module mutates global variables.
 * @param moduleValue The module value to check.
 * @returns true if the module mutates global variables.
 */
predicate mutates_globals(ModuleValue moduleValue) {
  // Check globals() function calls and related operations
  exists(CallNode globalsCall |
    globalsCall = Value::named("globals").(FunctionValue).getACall() and
    globalsCall.getScope() = moduleValue.getScope()
  |
    exists(AttrNode attrNode | attrNode.getObject() = globalsCall) or
    exists(SubscriptNode subNode | 
      subNode.getObject() = globalsCall and 
      subNode.isStore()
    )
  )
  or
  // Handle special Enum class global mutation cases
  exists(ClassValue enumClass |
    enumClass.getASuperType() = Value::named("enum.Enum") and
    (
      // Python < 3.8 _convert method handling
      exists(Value enumConvert |
        enumConvert = enumClass.attr("_convert") and
        exists(CallNode call | call.getScope() = moduleValue.getScope() |
          enumConvert.getACall() = call or
          call.getFunction().pointsTo(enumConvert)
        )
      )
      or
      // Python 3.8+ _convert_ method handling
      not exists(enumClass.attr("_convert")) and
      exists(CallNode call | call.getScope() = moduleValue.getScope() |
        call.getFunction().(AttrNode)
          .getObject(["_convert", "_convert_"])
          .pointsTo() = enumClass
      )
    )
  )
}

/**
 * Holds if the given name is the name of an exported submodule.
 * @param moduleValue The module value.
 * @param nameString The name to check.
 * @returns true if the name is an exported submodule.
 */
predicate is_exported_submodule_name(ModuleValue moduleValue, string nameString) {
  moduleValue.getScope().getShortName() = "__init__" and // Confirm __init__.py module
  exists(moduleValue.getScope().getPackage().getSubModule(nameString)) // Verify submodule exists
}

/**
 * Holds if the module contains an unresolved star import.
 * @param moduleValue The module value to check.
 * @returns true if there is an unresolved star import.
 */
predicate contains_unknown_import_star(ModuleValue moduleValue) {
  exists(ImportStarNode importStarNode | 
    importStarNode.getEnclosingModule() = moduleValue.getScope() and
    (
      importStarNode.getModule().pointsTo().isAbsent() or
      not exists(importStarNode.getModule().pointsTo())
    )
  )
}

from ModuleValue moduleValue, StringLiteral exportNameLiteral, string nameString
where
  // The name is declared in the module's __all__ list
  declaredInAll(moduleValue.getScope(), exportNameLiteral) and
  // Get the text representation of the name
  nameString = exportNameLiteral.getText() and
  // The module does not define the attribute
  not moduleValue.hasAttribute(nameString) and
  // The name is not an exported submodule
  not is_exported_submodule_name(moduleValue, nameString) and
  // The module does not contain an unresolved star import
  not contains_unknown_import_star(moduleValue) and
  // The module does not mutate global variables
  not mutates_globals(moduleValue)
select exportNameLiteral, "The name '" + nameString + "' is exported by __all__ but is not defined."