/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes that define the same attribute, 
 *              which may cause unexpected behavior due to attribute resolution ambiguity.
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
 * 检查函数是否只有空实现（仅包含pass语句或仅包含文档字符串）
 */
predicate has_trivial_implementation(PyFunctionObject function) {
  // 函数体中所有语句必须是pass语句或文档字符串表达式
  not exists(Stmt stmt | stmt.getScope() = function.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

/**
 * 检查函数是否使用super()调用父类同名方法，以实现正确的方法解析顺序
 */
predicate uses_super_resolution(FunctionObject function) {
  // 查找函数体内的super()调用模式：super().method_name()
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = function.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = function.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * 定义应从冲突分析中排除的属性
 * 这些属性在多继承场景中通常被有意覆盖，或由Python运行时特殊处理
 */
predicate is_attribute_exempted(string attributeName) {
  // 根据Python文档，process_request在多继承中常见且由运行时处理，故排除
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject parentClass1, 
  ClassObject parentClass2, 
  string attributeName, 
  int parentClass1Index, 
  int parentClass2Index, 
  Object attributeInBaseClass1, 
  Object attributeInBaseClass2
where
  // 建立继承关系：派生类有两个不同的父类
  derivedClass.getBaseType(parentClass1Index) = parentClass1 and
  derivedClass.getBaseType(parentClass2Index) = parentClass2 and
  parentClass1Index < parentClass2Index and
  
  // 检测同名属性冲突：两个父类定义相同属性但实现不同
  attributeInBaseClass1 = parentClass1.lookupAttribute(attributeName) and
  attributeInBaseClass2 = parentClass2.lookupAttribute(attributeName) and
  attributeInBaseClass1 != attributeInBaseClass2 and
  
  // 应用过滤条件减少误报
  (
    // 排除特殊方法和已知安全属性
    not attributeName.matches("\\_\\_%\\_\\_") and
    not is_attribute_exempted(attributeName) and
    
    // 派生类未覆盖该属性
    not derivedClass.declaresAttribute(attributeName)
  ) and
  
  // 排除已正确处理的方法解析场景
  (
    // 父类1未使用super()处理冲突
    not uses_super_resolution(attributeInBaseClass1) and
    
    // 父类2不是空实现（避免误报抽象方法）
    not has_trivial_implementation(attributeInBaseClass2)
  ) and
  
  // 确保属性间不存在覆盖关系
  (
    not attributeInBaseClass1.overrides(attributeInBaseClass2) and
    not attributeInBaseClass2.overrides(attributeInBaseClass1)
  )
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBaseClass1, attributeInBaseClass1.toString(), 
  attributeInBaseClass2, attributeInBaseClass2.toString()