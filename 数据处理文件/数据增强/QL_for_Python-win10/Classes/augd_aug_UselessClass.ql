/**
 * @name Useless class
 * @description Class only defines one public method (apart from `__init__` or `__new__`) and should be replaced by a function
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/useless-class
 */

import python

// 综合判断类是否为无用类（内联所有检查条件）
predicate is_useless_class(Class cls, int pubMethodCount) {
  // 计算公共方法数量（排除初始化方法）
  pubMethodCount = count(Function m |
    m = cls.getAMethod() and
    not m = cls.getInitMethod()
  ) and
  (pubMethodCount = 0 or pubMethodCount = 1) and
  
  // 检查类是否未定义特殊方法
  not exists(Function specialMethod |
    specialMethod = cls.getAMethod() and
    specialMethod.isSpecialMethod()
  ) and
  
  // 检查类是否没有继承关系（仅继承object）
  // 验证类没有父类（除object外）
  not exists(ClassValue curr, ClassValue par |
    curr.getScope() = cls and
    par != ClassValue::object()
  |
    par.getABaseType() = curr or
    curr.getABaseType() = par
  ) and
  // 验证基类仅为object
  not exists(Expr base |
    base = cls.getABase() and
    (not base instanceof Name or base.(Name).getId() != "object")
  ) and
  
  // 检查类是否未被装饰器修饰
  not exists(cls.getADecorator()) and
  
  // 检查类是否不维护状态（通过属性操作或特定方法调用）
  not (
    // 检查方法中是否存在属性存储操作
    exists(Function stateMethod, ExprContext ctx |
      stateMethod.getScope() = cls and
      (ctx instanceof Store or ctx instanceof AugStore)
    |
      exists(Subscript sub |
        sub.getScope() = stateMethod and
        sub.getCtx() = ctx
      )
      or
      exists(Attribute attr |
        attr.getScope() = stateMethod and
        attr.getCtx() = ctx
      )
    )
    // 检查方法中是否存在状态修改方法调用
    or
    exists(Function stateMethod, Call call, Attribute attr, string methodName |
      stateMethod.getScope() = cls and
      call.getScope() = stateMethod and
      call.getFunc() = attr and
      attr.getName() = methodName
    |
      methodName in ["pop", "remove", "discard", "extend", "append"]
    )
  ) and
  
  // 基本类属性检查
  cls.isTopLevel() and
  cls.isPublic() and
  not cls.isProbableMixin()
}

// 查询无用类并生成诊断消息
from Class cls, int pubMethodCount, string diagnosticMessage
where
  is_useless_class(cls, pubMethodCount) and
  (
    pubMethodCount = 1 and
    diagnosticMessage =
      "Class " + cls.getName() +
        " defines only one public method, which should be replaced by a function."
    or
    pubMethodCount = 0 and
    diagnosticMessage =
      "Class " + cls.getName() +
        " defines no public methods and could be replaced with a namedtuple or dictionary."
  )
select cls, diagnosticMessage