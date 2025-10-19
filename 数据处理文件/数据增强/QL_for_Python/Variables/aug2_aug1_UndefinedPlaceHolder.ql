/**
 * @name Use of an undefined placeholder variable
 * @description Identifies instances where placeholder variables are used without proper initialization,
 *              potentially leading to runtime errors or unexpected behavior in Python applications.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/undefined-placeholder-variable
 */

import python
import Variables.MonkeyPatched

// 检查占位符是否作为局部变量被初始化
predicate isInitializedAsLocalVariable(PlaceHolder varUsage) {
  exists(SsaVariable ssaVariable, Function enclosingFunction | 
    enclosingFunction = varUsage.getScope() and 
    ssaVariable.getAUse() = varUsage.getAFlowNode() |
    ssaVariable.getVariable() instanceof LocalVariable and
    not ssaVariable.maybeUndefined()
  )
}

// 获取包含占位符使用的封闭类
Class getEnclosingClass(PlaceHolder varUsage) { 
  result.getAMethod() = varUsage.getScope() 
}

// 检查占位符是否为模板属性
predicate isTemplateAttribute(PlaceHolder varUsage) {
  exists(ImportTimeScope classDefScope | 
    classDefScope = getEnclosingClass(varUsage) | 
    classDefScope.definesName(varUsage.getId())
  )
}

// 检查占位符是否不是模块属性
predicate isNotModuleAttribute(PlaceHolder varUsage) {
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(varUsage.getId()) and 
    moduleObject.getModule() = varUsage.getEnclosingModule()
  )
}

// 检查占位符是否不是猴子补丁的内置变量
predicate isNotMonkeyPatchedBuiltin(PlaceHolder varUsage) {
  not monkey_patched_builtin(varUsage.getId())
}

// 检查占位符是否不是全局定义名称
predicate isNotGloballyDefinedName(PlaceHolder varUsage) {
  not globallyDefinedName(varUsage.getId())
}

// 检查占位符是否不是全局变量、猴子补丁的内置变量或全局定义名称
predicate isNotGlobalVariable(PlaceHolder varUsage) {
  isNotModuleAttribute(varUsage) and
  isNotMonkeyPatchedBuiltin(varUsage) and
  isNotGloballyDefinedName(varUsage)
}

// 主查询：查找并报告可能未定义的占位符变量使用情况
from PlaceHolder targetPlaceholder
where
  not isInitializedAsLocalVariable(targetPlaceholder) and
  not isTemplateAttribute(targetPlaceholder) and
  isNotGlobalVariable(targetPlaceholder)
select targetPlaceholder, "This use of placeholder variable '" + targetPlaceholder.getId() + "' may be undefined."