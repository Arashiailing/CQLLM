/**
 * @name Use of an undefined placeholder variable
 * @description Detects usage of placeholder variables before they are initialized, which may cause runtime exceptions.
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

// 检查占位符变量是否在局部作用域中被初始化
predicate isLocallyInitialized(PlaceHolder placeholderUsage) {
  exists(SsaVariable ssaVar, Function enclosingFunction | 
    enclosingFunction = placeholderUsage.getScope() and 
    ssaVar.getAUse() = placeholderUsage.getAFlowNode() |
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

// 获取包含占位符使用的封闭类
Class getContainingClass(PlaceHolder placeholderUsage) { 
  result.getAMethod() = placeholderUsage.getScope() 
}

// 检查占位符是否作为模板属性在类中定义
predicate isDefinedAsTemplateAttribute(PlaceHolder placeholderUsage) {
  exists(ImportTimeScope classScope | 
    classScope = getContainingClass(placeholderUsage) | 
    classScope.definesName(placeholderUsage.getId())
  )
}

// 检查占位符是否不是全局变量、猴子补丁的内置变量或全局定义名称
predicate isNotGloballyDefined(PlaceHolder placeholderUsage) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(placeholderUsage.getId()) and 
    moduleObj.getModule() = placeholderUsage.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholderUsage.getId()) and
  not monkey_patched_builtin(placeholderUsage.getId())
}

// 主查询：查找并报告可能未定义的占位符变量使用情况
from PlaceHolder placeholder
where
  not isLocallyInitialized(placeholder) and
  not isDefinedAsTemplateAttribute(placeholder) and
  isNotGloballyDefined(placeholder)
select placeholder, "This use of placeholder variable '" + placeholder.getId() + "' may be undefined."