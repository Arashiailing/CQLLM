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

// 检查占位符变量是否已作为局部变量初始化
predicate isInitializedAsLocal(PlaceHolder placeholderVar) {
  exists(SsaVariable ssaVariable, Function function | 
    function = placeholderVar.getScope() and 
    ssaVariable.getAUse() = placeholderVar.getAFlowNode() |
    ssaVariable.getVariable() instanceof LocalVariable and
    not ssaVariable.maybeUndefined()
  )
}

// 获取包含占位符变量使用的封闭类
Class getEnclosingClass(PlaceHolder placeholderVar) { 
  result.getAMethod() = placeholderVar.getScope() 
}

// 检查占位符变量是否为模板属性
predicate isTemplateAttribute(PlaceHolder placeholderVar) {
  exists(ImportTimeScope classDefinitionScope | 
    classDefinitionScope = getEnclosingClass(placeholderVar) | 
    classDefinitionScope.definesName(placeholderVar.getId())
  )
}

// 检查占位符变量是否不是全局变量、猴子补丁的内置变量或全局定义名称
predicate isNotGlobalVariable(PlaceHolder placeholderVar) {
  not exists(PythonModuleObject moduleObject |
    moduleObject.hasAttribute(placeholderVar.getId()) and 
    moduleObject.getModule() = placeholderVar.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholderVar.getId()) and
  not monkey_patched_builtin(placeholderVar.getId())
}

// 主查询：查找并报告可能未定义的占位符变量使用情况
from PlaceHolder placeholderVar
where
  not isInitializedAsLocal(placeholderVar) and
  not isTemplateAttribute(placeholderVar) and
  isNotGlobalVariable(placeholderVar)
select placeholderVar, "This use of placeholder variable '" + placeholderVar.getId() + "' may be undefined."