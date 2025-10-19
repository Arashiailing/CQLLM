/**
 * @name 基类中的属性冲突
 * @description 检测继承自多个基类的类，其中多个基类定义了相同名称的属性。这种冲突可能导致由于属性解析歧义而产生意外行为。
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
 * 检查函数实现是否为空（仅包含pass语句或文档字符串）
 */
predicate is_empty_implementation(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * 检查函数是否显式调用了super()来进行方法解析
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
 * 识别冲突检测中豁免的属性名称
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
  string conflictingAttrName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attrInFirstBase, 
  Object attrInSecondBase
where
  // 建立继承关系：派生类继承自两个不同的基类（按继承顺序）
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // 在两个基类中定位相同名称的属性（确保是不同对象）
  attrInFirstBase != attrInSecondBase and
  attrInFirstBase = firstBaseClass.lookupAttribute(conflictingAttrName) and
  attrInSecondBase = secondBaseClass.lookupAttribute(conflictingAttrName) and
  
  // 排除特殊方法（双下划线包围的方法）和已知豁免属性
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttrName) and
  
  // 排除已通过super()调用处理方法解析的情况
  not invokes_super(attrInFirstBase) and
  
  // 忽略第二个基类中的空实现（通常不会造成实际冲突）
  not is_empty_implementation(attrInSecondBase) and
  
  // 确保两个属性间不存在覆盖关系
  not attrInFirstBase.overrides(attrInSecondBase) and
  not attrInSecondBase.overrides(attrInFirstBase) and
  
  // 确保派生类没有显式声明该属性（否则冲突会被解决）
  not derivedClass.declaresAttribute(conflictingAttrName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  attrInFirstBase, attrInFirstBase.toString(), 
  attrInSecondBase, attrInSecondBase.toString()