/**
 * @name 基类中的属性冲突检测
 * @description 识别继承自多个基类的类中存在的同名属性冲突。这种多继承场景下的属性命名冲突
 *              可能导致运行时行为不可预测，影响代码的可靠性和维护性。
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
predicate is_empty_implementation(PyFunctionObject function) {
  not exists(Stmt statement | statement.getScope() = function.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

/**
 * 判断函数是否通过显式调用super()来处理方法解析顺序
 */
predicate invokes_super(FunctionObject function) {
  exists(Call superInvocation, Call methodCall, Attribute attributeRef, GlobalVariable superVariable |
    methodCall.getScope() = function.getFunction() and
    methodCall.getFunc() = attributeRef and
    attributeRef.getObject() = superInvocation and
    attributeRef.getName() = function.getName() and
    superInvocation.getFunc() = superVariable.getAnAccess() and
    superVariable.getId() = "super"
  )
}

/**
 * 识别在冲突检测中应豁免的属性名称
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * 根据Python官方文档，socketserver模块中的process_request方法被豁免：
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   * 这是Python多继承设计中的特例，不应视为冲突
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject baseClassA, 
  ClassObject baseClassB, 
  string attributeName, 
  int inheritanceOrderA, 
  int inheritanceOrderB, 
  Object attributeInBaseA, 
  Object attributeInBaseB
where
  // 确保派生类继承自两个不同的基类，并记录继承顺序
  derivedClass.getBaseType(inheritanceOrderA) = baseClassA and
  derivedClass.getBaseType(inheritanceOrderB) = baseClassB and
  inheritanceOrderA < inheritanceOrderB and
  
  // 识别两个基类中的同名属性，并确保它们是不同的对象实例
  attributeInBaseA != attributeInBaseB and
  attributeInBaseA = baseClassA.lookupAttribute(attributeName) and
  attributeInBaseB = baseClassB.lookupAttribute(attributeName) and
  
  // 排除Python特殊方法（双下划线包围的方法）和已知豁免属性
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // 排除已通过super()调用显式处理方法解析顺序的情况
  not invokes_super(attributeInBaseA) and
  
  // 忽略第二个基类中的空实现，因为它们通常不会造成实际冲突
  not is_empty_implementation(attributeInBaseB) and
  
  // 确保两个属性间不存在覆盖关系（即它们不是重写关系）
  not attributeInBaseA.overrides(attributeInBaseB) and
  not attributeInBaseB.overrides(attributeInBaseA) and
  
  // 确保派生类没有显式声明该属性，否则冲突会被派生类解决
  not derivedClass.declaresAttribute(attributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBaseA, attributeInBaseA.toString(), 
  attributeInBaseB, attributeInBaseB.toString()