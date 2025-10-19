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
 * 检查指定名称是否在模块的 __all__ 列表中声明
 * @param mod 目标模块
 * @param nameLiteral 字符串字面量表示的名称
 * @returns 当名称存在于 __all__ 列表时返回 true
 */
predicate declaredInAll(Module mod, StringLiteral nameLiteral) {
  exists(Assign assignStmt, GlobalVariable allVar |
    assignStmt.defines(allVar) and // 定位定义 __all__ 的赋值语句
    assignStmt.getScope() = mod and // 确保赋值发生在目标模块内
    allVar.getId() = "__all__" and // 验证变量名为 __all__
    assignStmt.getValue().(List).getAnElt() = nameLiteral // 检查名称是否在列表中
  )
}

/**
 * 检测模块是否修改了全局变量
 * @param modVal 待检查的模块值
 * @returns 当模块修改全局变量时返回 true
 */
predicate mutates_globals(ModuleValue modVal) {
  // 检查 globals() 函数调用及其相关操作
  exists(CallNode globalsCall |
    globalsCall = Value::named("globals").(FunctionValue).getACall() and
    globalsCall.getScope() = modVal.getScope()
  |
    exists(AttrNode attrNode | attrNode.getObject() = globalsCall) or
    exists(SubscriptNode subNode | 
      subNode.getObject() = globalsCall and 
      subNode.isStore()
    )
  )
  or
  // 处理 Enum 类的特殊全局变量修改情况
  exists(ClassValue enumClass |
    enumClass.getASuperType() = Value::named("enum.Enum") and
    (
      // Python < 3.8 的 _convert 方法处理
      exists(Value enumConvert |
        enumConvert = enumClass.attr("_convert") and
        exists(CallNode call | call.getScope() = modVal.getScope() |
          enumConvert.getACall() = call or
          call.getFunction().pointsTo(enumConvert)
        )
      )
      or
      // Python 3.8+ 的 _convert_ 方法处理
      not exists(enumClass.attr("_convert")) and
      exists(CallNode call | call.getScope() = modVal.getScope() |
        call.getFunction().(AttrNode)
          .getObject(["_convert", "_convert_"])
          .pointsTo() = enumClass
      )
    )
  )
}

/**
 * 验证名称是否为导出的子模块名称
 * @param modVal 模块值
 * @param nameStr 待检查的名称
 * @returns 当名称是导出的子模块时返回 true
 */
predicate is_exported_submodule_name(ModuleValue modVal, string nameStr) {
  modVal.getScope().getShortName() = "__init__" and // 确认是 __init__.py 模块
  exists(modVal.getScope().getPackage().getSubModule(nameStr)) // 验证子模块存在
}

/**
 * 检查模块是否包含未解析的星号导入
 * @param modVal 待检查的模块值
 * @returns 当存在未知星号导入时返回 true
 */
predicate contains_unknown_import_star(ModuleValue modVal) {
  exists(ImportStarNode importStarNode | 
    importStarNode.getEnclosingModule() = modVal.getScope() and
    (
      importStarNode.getModule().pointsTo().isAbsent() or
      not exists(importStarNode.getModule().pointsTo())
    )
  )
}

from ModuleValue modVal, StringLiteral nameLiteral, string nameStr
where
  declaredInAll(modVal.getScope(), nameLiteral) and // 名称在 __all__ 中声明
  nameStr = nameLiteral.getText() and // 获取文本表示
  not modVal.hasAttribute(nameStr) and // 模块未定义该属性
  not is_exported_submodule_name(modVal, nameStr) and // 非导出子模块
  not contains_unknown_import_star(modVal) and // 无未知星号导入
  not mutates_globals(modVal) // 未修改全局变量
select nameLiteral, "The name '" + nameStr + "' is exported by __all__ but is not defined."