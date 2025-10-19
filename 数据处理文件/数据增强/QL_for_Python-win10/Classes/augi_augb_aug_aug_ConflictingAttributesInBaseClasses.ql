/**
 * @name 基类中的属性冲突
 * @description 检测多重继承时，不同基类中存在同名属性但未妥善处理的冲突情况。
 *              这种冲突可能导致属性解析时的歧义和不可预测的行为。
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
 * 判断函数是否为空实现（仅包含pass语句或文档字符串）
 */
predicate isEmptyImplementation(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * 判断函数是否通过显式调用super()来使用方法解析顺序(MRO)
 */
predicate usesSuperCall(FunctionObject func) {
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
  ClassObject derivedClass, 
  ClassObject parentClass1, 
  ClassObject parentClass2, 
  string attributeName, 
  int parentIndex1, 
  int parentIndex2, 
  Object attributeInParent1, 
  Object attributeInParent2
where
  // 建立多重继承关系：派生类继承自两个不同的父类
  derivedClass.getBaseType(parentIndex1) = parentClass1 and
  derivedClass.getBaseType(parentIndex2) = parentClass2 and
  parentIndex1 < parentIndex2 and
  
  // 在两个父类中定位同名但不同的属性
  attributeInParent1 != attributeInParent2 and
  attributeInParent1 = parentClass1.lookupAttribute(attributeName) and
  attributeInParent2 = parentClass2.lookupAttribute(attributeName) and
  
  // 排除特殊方法（双下划线包围）和已知豁免属性
  not attributeName.matches("\\_\\_%\\_\\_") and
  not isExemptAttribute(attributeName) and
  
  // 排除已通过super()调用处理方法解析的情况
  not usesSuperCall(attributeInParent1) and
  
  // 忽略第二个父类中的空实现（通常不会造成实际冲突）
  not isEmptyImplementation(attributeInParent2) and
  
  // 确保两个属性间不存在覆盖关系
  not attributeInParent1.overrides(attributeInParent2) and
  not attributeInParent2.overrides(attributeInParent1) and
  
  // 确保派生类没有显式声明该属性（否则冲突会被解决）
  not derivedClass.declaresAttribute(attributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInParent1, attributeInParent1.toString(), 
  attributeInParent2, attributeInParent2.toString()