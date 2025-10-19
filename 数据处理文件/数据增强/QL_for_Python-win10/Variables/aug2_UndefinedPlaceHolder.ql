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

// 检查占位符变量是否在局部作用域内被初始化
predicate is_locally_initialized(PlaceHolder placeholder_usage) {
  exists(SsaVariable local_ssa, Function containing_function | 
    containing_function = placeholder_usage.getScope() and 
    local_ssa.getAUse() = placeholder_usage.getAFlowNode() |
    local_ssa.getVariable() instanceof LocalVariable and
    not local_ssa.maybeUndefined()
  )
}

// 获取包含占位符使用的类
Class get_enclosing_class(PlaceHolder placeholder_usage) { 
  result.getAMethod() = placeholder_usage.getScope() 
}

// 检查占位符是否为模板属性
predicate is_template_attribute(PlaceHolder placeholder_usage) {
  exists(ImportTimeScope class_scope | 
    class_scope = get_enclosing_class(placeholder_usage) | 
    class_scope.definesName(placeholder_usage.getId())
  )
}

// 检查占位符是否不是全局变量
predicate is_not_global_variable(PlaceHolder placeholder_usage) {
  // 确保变量不是模块属性、全局定义名称或猴子补丁的内置变量
  not exists(PythonModuleObject module_obj |
    module_obj.hasAttribute(placeholder_usage.getId()) and 
    module_obj.getModule() = placeholder_usage.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholder_usage.getId()) and
  not monkey_patched_builtin(placeholder_usage.getId())
}

// 主查询：查找可能未定义的占位符变量使用
from PlaceHolder placeholder_var
where
  not is_locally_initialized(placeholder_var) and
  not is_template_attribute(placeholder_var) and
  is_not_global_variable(placeholder_var)
select placeholder_var, "This use of place-holder variable '" + placeholder_var.getId() + "' may be undefined."