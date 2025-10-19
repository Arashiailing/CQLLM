/**
 * @name Undefined Placeholder Variable Usage
 * @description Identifies placeholder variables that are referenced without prior initialization,
 *              potentially leading to runtime errors during program execution.
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
predicate is_locally_initialized(PlaceHolder placeholder_ref) {
  exists(SsaVariable ssa_definition, Function enclosing_function | 
    enclosing_function = placeholder_ref.getScope() and 
    ssa_definition.getAUse() = placeholder_ref.getAFlowNode() |
    ssa_definition.getVariable() instanceof LocalVariable and
    not ssa_definition.maybeUndefined()
  )
}

// 获取包含占位符使用的类
Class get_enclosing_class(PlaceHolder placeholder_ref) { 
  result.getAMethod() = placeholder_ref.getScope() 
}

// 检查占位符是否为模板属性
predicate is_template_attribute(PlaceHolder placeholder_ref) {
  exists(ImportTimeScope template_scope | 
    template_scope = get_enclosing_class(placeholder_ref) | 
    template_scope.definesName(placeholder_ref.getId())
  )
}

// 检查占位符是否不是全局变量
predicate is_not_global_variable(PlaceHolder placeholder_ref) {
  // 确保变量不是模块属性、全局定义名称或猴子补丁的内置变量
  not exists(PythonModuleObject module_context |
    module_context.hasAttribute(placeholder_ref.getId()) and 
    module_context.getModule() = placeholder_ref.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholder_ref.getId()) and
  not monkey_patched_builtin(placeholder_ref.getId())
}

// 主查询：查找可能未定义的占位符变量使用
from PlaceHolder suspect_placeholder
where
  not is_locally_initialized(suspect_placeholder) and
  not is_template_attribute(suspect_placeholder) and
  is_not_global_variable(suspect_placeholder)
select suspect_placeholder, "This use of place-holder variable '" + suspect_placeholder.getId() + "' may be undefined."