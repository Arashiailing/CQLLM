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
predicate initialized_as_local(PlaceHolder varUsage) {
  exists(SsaVariable ssaLocalVar, Function parentFunction | 
    parentFunction = varUsage.getScope() and 
    ssaLocalVar.getAUse() = varUsage.getAFlowNode() |
    ssaLocalVar.getVariable() instanceof LocalVariable and
    not ssaLocalVar.maybeUndefined()
  )
}

// 获取使用变量的封闭类
Class enclosing_class(PlaceHolder varUsage) { 
  result.getAMethod() = varUsage.getScope() 
}

// 检查变量是否是模板属性
predicate template_attribute(PlaceHolder varUsage) {
  exists(ImportTimeScope classDefinitionScope | 
    classDefinitionScope = enclosing_class(varUsage) and 
    classDefinitionScope.definesName(varUsage.getId())
  )
}

// 检查变量是否不是全局变量
predicate not_a_global(PlaceHolder varUsage) {
  // 确保变量不是模块属性、全局定义的名称或猴子补丁的内置变量
  not exists(PythonModuleObject moduleEntity |
    moduleEntity.hasAttribute(varUsage.getId()) and 
    moduleEntity.getModule() = varUsage.getEnclosingModule()
  ) and
  not globallyDefinedName(varUsage.getId()) and
  not monkey_patched_builtin(varUsage.getId())
}

// 查询未初始化的占位符变量
from PlaceHolder placeholderVariable
where
  // 排除已初始化的局部变量、模板属性和全局变量
  not initialized_as_local(placeholderVariable) and
  not template_attribute(placeholderVariable) and
  not_a_global(placeholderVariable)
select placeholderVariable, "This use of place-holder variable '" + placeholderVariable.getId() + "' may be undefined."