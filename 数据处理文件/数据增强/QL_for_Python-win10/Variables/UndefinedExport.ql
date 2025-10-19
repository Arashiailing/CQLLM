/**
 * @name Explicit export is not defined
 * @description Including an undefined attribute in `__all__` causes an exception when
 *              the module is imported using '*'
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/undefined-export
 */

import python

/** 
 * 判断给定名称是否在模块的 __all__ 列表中声明
 * @param m 模块
 * @param name 字符串字面量，表示要检查的名称
 * @return 如果名称在 __all__ 列表中声明，则返回 true；否则返回 false
 */
predicate declaredInAll(Module m, StringLiteral name) {
  exists(Assign a, GlobalVariable all |
    a.defines(all) and // 查找定义了全局变量 all 的赋值语句
    a.getScope() = m and // 确保赋值语句在当前模块范围内
    all.getId() = "__all__" and // 确保全局变量的名称是 "__all__"
    a.getValue().(List).getAnElt() = name // 确保 __all__ 列表中包含指定名称
  )
}

/**
 * 判断模块是否修改了全局变量
 * @param m 模块值
 * @return 如果模块修改了全局变量，则返回 true；否则返回 false
 */
predicate mutates_globals(ModuleValue m) {
  exists(CallNode globals |
    globals = Value::named("globals").(FunctionValue).getACall() and // 查找调用 globals() 函数的节点
    globals.getScope() = m.getScope() // 确保调用发生在当前模块范围内
  |
    exists(AttrNode attr | attr.getObject() = globals) or // 检查对 globals() 返回对象的任何属性访问
    exists(SubscriptNode sub | sub.getObject() = globals and sub.isStore()) // 检查对 globals() 返回对象的任何存储操作
  )
  or
  // Enum (added in 3.4) has method `_convert_` that alters globals
  // This was called `_convert` until 3.8, but that name will be removed in 3.9
  exists(ClassValue enum_class |
    enum_class.getASuperType() = Value::named("enum.Enum") and // 查找继承自 enum.Enum 的类
    (
      // In Python < 3.8, Enum._convert can be found with points-to
      exists(Value enum_convert |
        enum_convert = enum_class.attr("_convert") and // 查找 _convert 方法
        exists(CallNode call | call.getScope() = m.getScope() |
          enum_convert.getACall() = call or // 查找对 _convert 方法的调用
          call.getFunction().pointsTo(enum_convert) // 或者指向 _convert 方法的调用
        )
      )
      or
      // In Python 3.8, Enum._convert_ is implemented using a metaclass, and our points-to
      // analysis doesn't handle that well enough. So we need a special case for this
      not exists(enum_class.attr("_convert")) and // 在 Python 3.8+ 中，没有 _convert 方法
      exists(CallNode call | call.getScope() = m.getScope() |
        call.getFunction().(AttrNode).getObject(["_convert", "_convert_"]).pointsTo() = enum_class // 查找对 _convert_ 方法的调用
      )
    )
  )
}

/**
 * 判断给定名称是否是导出的子模块名称
 * @param m 模块值
 * @param exported_name 导出的名称
 * @return 如果名称是导出的子模块名称，则返回 true；否则返回 false
 */
predicate is_exported_submodule_name(ModuleValue m, string exported_name) {
  m.getScope().getShortName() = "__init__" and // 确保模块是 __init__.py
  exists(m.getScope().getPackage().getSubModule(exported_name)) // 确保包中存在指定名称的子模块
}

/**
 * 判断模块是否包含未知的星号导入
 * @param m 模块值
 * @return 如果模块包含未知的星号导入，则返回 true；否则返回 false
 */
predicate contains_unknown_import_star(ModuleValue m) {
  exists(ImportStarNode imp | imp.getEnclosingModule() = m.getScope() |
    imp.getModule().pointsTo().isAbsent() or // 检查导入的模块是否不存在
    not exists(imp.getModule().pointsTo()) // 或者无法确定导入的模块
  )
}

from ModuleValue m, StringLiteral name, string exported_name
where
  declaredInAll(m.getScope(), name) and // 名称在 __all__ 列表中声明
  exported_name = name.getText() and // 导出的名称与名称文本相同
  not m.hasAttribute(exported_name) and // 模块中没有定义该名称的属性
  not is_exported_submodule_name(m, exported_name) and // 名称不是导出的子模块名称
  not contains_unknown_import_star(m) and // 模块不包含未知的星号导入
  not mutates_globals(m) // 模块不修改全局变量
select name, "The name '" + exported_name + "' is exported by __all__ but is not defined." // 选择未定义但被导出的名称并报告问题
