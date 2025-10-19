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
 * 判断函数实现是否为空实现（仅包含pass语句或文档字符串）
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
  ClassObject subClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string conflictingPropertyName, 
  int baseIndex1, 
  int baseIndex2, 
  Object propertyInBase1, 
  Object propertyInBase2
where
  // 建立多重继承关系：子类继承自两个不同的基类
  subClass.getBaseType(baseIndex1) = baseClass1 and
  subClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  
  // 在两个基类中定位同名但不同的属性
  propertyInBase1 != propertyInBase2 and
  propertyInBase1 = baseClass1.lookupAttribute(conflictingPropertyName) and
  propertyInBase2 = baseClass2.lookupAttribute(conflictingPropertyName) and
  
  // 排除特殊方法（双下划线包围）和已知豁免属性
  not conflictingPropertyName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingPropertyName) and
  
  // 排除已通过super()调用处理方法解析的情况
  not invokes_super(propertyInBase1) and
  
  // 忽略第二个基类中的空实现（通常不会造成实际冲突）
  not is_empty_implementation(propertyInBase2) and
  
  // 确保两个属性间不存在覆盖关系
  not propertyInBase1.overrides(propertyInBase2) and
  not propertyInBase2.overrides(propertyInBase1) and
  
  // 确保子类没有显式声明该属性（否则冲突会被解决）
  not subClass.declaresAttribute(conflictingPropertyName)
select subClass, 
  "Base classes have conflicting values for attribute '" + conflictingPropertyName + "': $@ and $@.", 
  propertyInBase1, propertyInBase1.toString(), 
  propertyInBase2, propertyInBase2.toString()