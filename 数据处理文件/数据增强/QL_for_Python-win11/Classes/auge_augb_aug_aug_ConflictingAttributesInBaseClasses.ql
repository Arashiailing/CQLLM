/**
 * @name 基类中的属性冲突
 * @description 检测在多重继承场景中，不同基类包含同名属性但未妥善处理的冲突。
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
  ClassObject parentClass1, 
  ClassObject parentClass2, 
  string conflictingAttrName, 
  int parentIndex1, 
  int parentIndex2, 
  Object attrInParent1, 
  Object attrInParent2
where
  // 检查多重继承关系：派生类继承自两个不同的父类
  derivedClass.getBaseType(parentIndex1) = parentClass1 and
  derivedClass.getBaseType(parentIndex2) = parentClass2 and
  parentIndex1 < parentIndex2 and
  
  // 确保两个父类中有同名但不同的属性
  attrInParent1 != attrInParent2 and
  attrInParent1 = parentClass1.lookupAttribute(conflictingAttrName) and
  attrInParent2 = parentClass2.lookupAttribute(conflictingAttrName) and
  
  // 排除特殊方法（双下划线包围）和已知豁免属性
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttrName) and
  
  // 确保属性冲突未被super()调用解决
  not invokes_super(attrInParent1) and
  
  // 忽略第二个父类中的空实现（通常不会导致实际问题）
  not is_empty_implementation(attrInParent2) and
  
  // 确保两个属性间不存在覆盖关系
  not attrInParent1.overrides(attrInParent2) and
  not attrInParent2.overrides(attrInParent1) and
  
  // 确保派生类没有显式声明该属性（否则冲突会被解决）
  not derivedClass.declaresAttribute(conflictingAttrName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  attrInParent1, attrInParent1.toString(), 
  attrInParent2, attrInParent2.toString()