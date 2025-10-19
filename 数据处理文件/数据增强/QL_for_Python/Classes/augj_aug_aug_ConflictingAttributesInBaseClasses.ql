/**
 * @name 多重继承中的属性冲突
 * @description 识别在多重继承场景下，派生类所继承的多个基类中存在同名属性的情况。这类冲突可能导致属性访问时的解析歧义，从而引发不可预期的运行时行为。
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
 * 判断函数实现是否为空实现（仅包含pass语句或文档字符串）
 */
predicate is_empty_implementation(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * 判断函数实现中是否通过super()显式调用父类方法以解决方法解析问题
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
 * 标识在属性冲突检测中应豁免的特殊属性名称
 */
predicate is_exempt_attribute(string attrName) {
  /*
   * 根据Python的socketserver模块文档，process_request方法被豁免：
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject childClass, 
  ClassObject primaryBaseClass, 
  ClassObject secondaryBaseClass, 
  string attributeName, 
  int primaryBaseIndex, 
  int secondaryBaseIndex, 
  Object attrInPrimaryBase, 
  Object attrInSecondaryBase
where
  // 建立继承关系：派生类继承自两个不同的基类（按继承顺序）
  childClass.getBaseType(primaryBaseIndex) = primaryBaseClass and
  childClass.getBaseType(secondaryBaseIndex) = secondaryBaseClass and
  primaryBaseIndex < secondaryBaseIndex and
  
  // 在两个基类中定位相同名称的属性（确保是不同对象）
  attrInPrimaryBase != attrInSecondaryBase and
  attrInPrimaryBase = primaryBaseClass.lookupAttribute(attributeName) and
  attrInSecondaryBase = secondaryBaseClass.lookupAttribute(attributeName) and
  
  // 排除特殊方法（双下划线包围的方法）和已知豁免属性
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // 排除已通过super()调用处理方法解析的情况
  not invokes_super(attrInPrimaryBase) and
  
  // 忽略第二个基类中的空实现（通常不会造成实际冲突）
  not is_empty_implementation(attrInSecondaryBase) and
  
  // 确保两个属性间不存在覆盖关系
  not attrInPrimaryBase.overrides(attrInSecondaryBase) and
  not attrInSecondaryBase.overrides(attrInPrimaryBase) and
  
  // 确保派生类没有显式声明该属性（否则冲突会被解决）
  not childClass.declaresAttribute(attributeName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attrInPrimaryBase, attrInPrimaryBase.toString(), 
  attrInSecondaryBase, attrInSecondaryBase.toString()