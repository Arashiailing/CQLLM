/**
 * @name Use of an undefined placeholder variable
 * @description Detects placeholder variables that are used before being initialized, which can cause runtime exceptions.
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

// 判断占位符变量是否在局部作用域内被初始化
predicate isLocallyInitialized(PlaceHolder placeholderRef) {
  exists(SsaVariable ssaVar, Function enclosingFunc | 
    // 占位符引用位于函数作用域内
    enclosingFunc = placeholderRef.getScope() and 
    // SSA变量与占位符引用相关联
    ssaVar.getAUse() = placeholderRef.getAFlowNode() |
    // SSA变量是局部变量且已定义
    ssaVar.getVariable() instanceof LocalVariable and
    not ssaVar.maybeUndefined()
  )
}

// 获取包含占位符引用的类
Class getEnclosingClass(PlaceHolder placeholderRef) { 
  // 类的方法包含占位符引用的作用域
  result.getAMethod() = placeholderRef.getScope() 
}

// 判断占位符是否为模板属性（在类作用域内定义）
predicate isTemplateAttribute(PlaceHolder placeholderRef) {
  exists(ImportTimeScope classScope | 
    // 获取包含占位符引用的类
    classScope = getEnclosingClass(placeholderRef) | 
    // 类作用域定义了占位符的名称
    classScope.definesName(placeholderRef.getId())
  )
}

// 判断占位符是否不是全局变量、模块属性或猴子补丁的内置变量
predicate isNotGlobalVariable(PlaceHolder placeholderRef) {
  // 确保变量不是模块属性
  not exists(PythonModuleObject moduleObj |
    moduleObj.hasAttribute(placeholderRef.getId()) and 
    moduleObj.getModule() = placeholderRef.getEnclosingModule()
  ) and
  // 确保变量不是全局定义名称
  not globallyDefinedName(placeholderRef.getId()) and
  // 确保变量不是猴子补丁的内置变量
  not monkey_patched_builtin(placeholderRef.getId())
}

// 主查询：查找可能未定义的占位符变量使用
from PlaceHolder undefinedPlaceholder
where
  // 排除在局部作用域内已初始化的占位符
  not isLocallyInitialized(undefinedPlaceholder) and
  // 排除作为模板属性的占位符
  not isTemplateAttribute(undefinedPlaceholder) and
  // 排除全局变量、模块属性和猴子补丁的内置变量
  isNotGlobalVariable(undefinedPlaceholder)
select undefinedPlaceholder, "This use of place-holder variable '" + undefinedPlaceholder.getId() + "' may be undefined."