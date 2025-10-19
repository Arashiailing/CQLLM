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

// 检查占位符是否已作为局部变量初始化
predicate isInitializedAsLocal(PlaceHolder placeholder) {
  exists(SsaVariable ssaVar, Function func | 
    func = placeholder.getScope() and 
    ssaVar.getAUse() = placeholder.getAFlowNode() |
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

// 获取包含占位符使用的封闭类
Class getEnclosingClass(PlaceHolder placeholder) { 
  result.getAMethod() = placeholder.getScope() 
}

// 检查占位符是否为模板属性
predicate isTemplateAttribute(PlaceHolder placeholder) {
  exists(ImportTimeScope classScope | 
    classScope = getEnclosingClass(placeholder) | 
    classScope.definesName(placeholder.getId())
  )
}

// 检查占位符是否不是全局变量、猴子补丁的内置变量或全局定义名称
predicate isNotGlobalVariable(PlaceHolder placeholder) {
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(placeholder.getId()) and 
    moduleObj.getModule() = placeholder.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholder.getId()) and
  not monkey_patched_builtin(placeholder.getId())
}

// 主查询：查找并报告可能未定义的占位符变量使用情况
from PlaceHolder placeholder
where
  not isInitializedAsLocal(placeholder) and
  not isTemplateAttribute(placeholder) and
  isNotGlobalVariable(placeholder)
select placeholder, "This use of placeholder variable '" + placeholder.getId() + "' may be undefined."