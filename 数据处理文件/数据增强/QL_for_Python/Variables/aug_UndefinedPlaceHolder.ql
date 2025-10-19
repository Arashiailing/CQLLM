/**
 * @name Use of an undefined placeholder variable
 * @description Detects usage of placeholder variables before they are initialized, which can cause runtime exceptions.
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

// 检查变量是否作为局部变量被初始化
predicate initialized_as_local(PlaceHolder variableUse) {
  exists(SsaVariable localSsaVar, Function enclosingFunction | 
    enclosingFunction = variableUse.getScope() and 
    localSsaVar.getAUse() = variableUse.getAFlowNode() |
    localSsaVar.getVariable() instanceof LocalVariable and
    not localSsaVar.maybeUndefined()
  )
}

// 获取使用变量的封闭类
Class enclosing_class(PlaceHolder variableUse) { 
  result.getAMethod() = variableUse.getScope() 
}

// 检查变量是否是模板属性
predicate template_attribute(PlaceHolder variableUse) {
  exists(ImportTimeScope classScope | 
    classScope = enclosing_class(variableUse) | 
    classScope.definesName(variableUse.getId())
  )
}

// 检查变量是否不是全局变量
predicate not_a_global(PlaceHolder variableUse) {
  // 确保变量不是模块属性、全局定义的名称或猴子补丁的内置变量
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(variableUse.getId()) and 
    moduleObj.getModule() = variableUse.getEnclosingModule()
  ) and
  not globallyDefinedName(variableUse.getId()) and
  not monkey_patched_builtin(variableUse.getId())
}

// 查询未初始化的占位符变量
from PlaceHolder placeholderVar
where
  // 排除已初始化的局部变量、模板属性和全局变量
  not initialized_as_local(placeholderVar) and
  not template_attribute(placeholderVar) and
  not_a_global(placeholderVar)
select placeholderVar, "This use of place-holder variable '" + placeholderVar.getId() + "' may be undefined."