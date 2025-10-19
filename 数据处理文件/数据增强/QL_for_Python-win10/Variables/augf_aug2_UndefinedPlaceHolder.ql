/**
 * @name Use of an undefined placeholder variable
 * @description Identifies placeholder variables that are referenced without proper initialization,
 *              potentially leading to runtime exceptions.
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

// 辅助谓词：获取包含占位符引用的类
Class get_enclosing_class(PlaceHolder placeholder_ref) { 
  result.getAMethod() = placeholder_ref.getScope() 
}

// 检查占位符是否为模板属性（在类作用域内定义）
predicate is_template_attribute(PlaceHolder placeholder_ref) {
  exists(ImportTimeScope class_definition | 
    class_definition = get_enclosing_class(placeholder_ref) | 
    class_definition.definesName(placeholder_ref.getId())
  )
}

// 检查占位符是否不是全局变量
predicate is_not_global_variable(PlaceHolder placeholder_ref) {
  // 确保占位符不是以下类型的变量：
  // 1. 模块属性
  // 2. 全局定义名称
  // 3. 猴子补丁的内置变量
  not exists(PythonModuleObject module_entity |
    module_entity.hasAttribute(placeholder_ref.getId()) and 
    module_entity.getModule() = placeholder_ref.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholder_ref.getId()) and
  not monkey_patched_builtin(placeholder_ref.getId())
}

// 检查占位符变量是否在局部作用域内被初始化
predicate is_locally_initialized(PlaceHolder placeholder_ref) {
  exists(SsaVariable ssa_var, Function enclosing_func | 
    enclosing_func = placeholder_ref.getScope() and 
    ssa_var.getAUse() = placeholder_ref.getAFlowNode() |
    ssa_var.getVariable() instanceof LocalVariable and
    not ssa_var.maybeUndefined()
  )
}

// 主查询：查找可能未定义的占位符变量引用
from PlaceHolder placeholder_usage
where
  // 排除已在局部作用域内初始化的占位符
  not is_locally_initialized(placeholder_usage) and
  // 排除是模板属性的占位符
  not is_template_attribute(placeholder_usage) and
  // 排除是全局变量的占位符
  is_not_global_variable(placeholder_usage)
select placeholder_usage, "This use of place-holder variable '" + placeholder_usage.getId() + "' may be undefined."