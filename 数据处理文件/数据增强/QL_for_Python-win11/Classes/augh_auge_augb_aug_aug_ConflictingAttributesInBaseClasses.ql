/**
 * @name 基类中的属性冲突
 * @description 检测多重继承场景中不同基类包含同名属性但未妥善处理的冲突。
 *              这些冲突可能导致属性解析时的歧义和不可预测的行为。
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/conflicting-attributes
 */

import python

/**
 * 判断函数实现是否为空（仅包含pass语句或文档字符串）
 */
predicate is_empty_implementation(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * 判断函数是否通过显式调用super()来使用方法解析顺序(MRO)
 */
predicate invokes_super(FunctionObject func) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * 识别在冲突检测中应豁免的特殊属性名称
 */
predicate is_exempt_attribute(string attrName) {
  /*
   * 根据Python的socketserver模块文档，process_request方法被豁免：
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttr, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attrInFirstBase, 
  Object attrInSecondBase
where
  // 多重继承关系验证：派生类继承自两个不同的父类
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // 同名属性冲突验证：两个父类存在同名但不同的属性
  attrInFirstBase != attrInSecondBase and
  attrInFirstBase = firstBaseClass.lookupAttribute(conflictingAttr) and
  attrInSecondBase = secondBaseClass.lookupAttribute(conflictingAttr) and
  
  // 属性类型过滤：排除特殊方法和已知豁免属性
  not conflictingAttr.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttr) and
  
  // 冲突解决状态验证：属性未被super()调用解决
  not invokes_super(attrInFirstBase) and
  
  // 实现有效性检查：忽略第二个父类中的空实现
  not is_empty_implementation(attrInSecondBase) and
  
  // 覆盖关系排除：确保两个属性间不存在覆盖关系
  not attrInFirstBase.overrides(attrInSecondBase) and
  not attrInSecondBase.overrides(attrInFirstBase) and
  
  // 派生类声明检查：确保派生类没有显式声明该属性
  not derivedClass.declaresAttribute(conflictingAttr)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttr + "': $@ and $@.", 
  attrInFirstBase, attrInFirstBase.toString(), 
  attrInSecondBase, attrInSecondBase.toString()