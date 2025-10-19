/**
 * @name 基类中的属性冲突
 * @description 识别在多重继承场景下，不同基类中存在同名属性但未妥善处理的冲突情况。
 *              此类冲突可能导致属性解析时的歧义和不可预测的行为。
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
 * 检测函数是否为空实现（仅包含pass语句或文档字符串）
 */
predicate isEmptyImplementation(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * 检测函数是否通过显式调用super()来使用方法解析顺序(MRO)
 */
predicate invokesSuper(FunctionObject func) {
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
predicate isExemptAttribute(string attrName) {
  /*
   * 根据Python的socketserver模块文档，process_request方法被豁免：
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject subClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttrName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object firstBaseProperty, 
  Object secondBaseProperty
where
  // 确立多重继承关系：子类继承自两个不同的基类
  subClass.getBaseType(firstBaseIndex) = firstBaseClass and
  subClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // 在两个基类中定位同名但不同的属性
  firstBaseProperty != secondBaseProperty and
  firstBaseProperty = firstBaseClass.lookupAttribute(conflictingAttrName) and
  secondBaseProperty = secondBaseClass.lookupAttribute(conflictingAttrName) and
  
  // 排除特殊方法（双下划线包围）和已知豁免属性
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and
  not isExemptAttribute(conflictingAttrName) and
  
  // 排除已通过super()调用处理方法解析的情况
  not invokesSuper(firstBaseProperty) and
  
  // 忽略第二个基类中的空实现（通常不会造成实际冲突）
  not isEmptyImplementation(secondBaseProperty) and
  
  // 确保两个属性间不存在覆盖关系
  not firstBaseProperty.overrides(secondBaseProperty) and
  not secondBaseProperty.overrides(firstBaseProperty) and
  
  // 确保子类没有显式声明该属性（否则冲突会被解决）
  not subClass.declaresAttribute(conflictingAttrName)
select subClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  firstBaseProperty, firstBaseProperty.toString(), 
  secondBaseProperty, secondBaseProperty.toString()