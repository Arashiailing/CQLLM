/**
 * @name Incomplete ordering
 * @description Class defines one or more ordering method but does not define all 4 ordering comparison methods
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/incomplete-ordering
 */

import python

// 检查类是否应用了total_ordering装饰器
predicate uses_total_ordering(Class targetClass) {
  exists(Attribute attr | attr = targetClass.getADecorator() | attr.getName() = "total_ordering") // 检查装饰器属性
  or
  exists(Name nameNode | nameNode = targetClass.getADecorator() | nameNode.getId() = "total_ordering") // 检查装饰器名称
}

// 根据索引获取比较方法的名称
string get_ordering_method_name(int index) {
  result = "__lt__" and index = 1 // 小于
  or
  result = "__le__" and index = 2 // 小于等于
  or
  result = "__gt__" and index = 3 // 大于
  or
  result = "__ge__" and index = 4 // 大于等于
}

// 检查类或其父类是否重写了指定的比较方法
predicate has_ordering_method(ClassValue targetCls, string methodName) {
  methodName = get_ordering_method_name(_) and ( // 确保是有效的比较方法名
    targetCls.declaresAttribute(methodName) // 类自身声明了该方法
    or
    exists(ClassValue superClass | superClass = targetCls.getASuperType() and not superClass = Value::named("object") | // 父类声明了该方法
      superClass.declaresAttribute(methodName)
    )
  )
}

// 获取类未实现的比较方法名称
string missing_ordering_method(ClassValue targetCls, int index) {
  not targetCls = Value::named("object") and // 排除object类
  not has_ordering_method(targetCls, result) and // 确保类及其父类未实现该方法
  result = get_ordering_method_name(index) // 获取对应索引的比较方法名
}

// 构建包含所有未实现比较方法的字符串
string get_missing_methods_string(ClassValue targetCls, int index) {
  // 初始化空字符串并检查是否有未实现的方法
  index = 0 and result = "" and exists(missing_ordering_method(targetCls, _))
  or
  // 递归构建结果字符串
  exists(string prefix, int prevIndex | index = prevIndex + 1 and prefix = get_missing_methods_string(targetCls, prevIndex) |
    // 如果前缀为空，直接添加当前方法名
    prefix = "" and result = missing_ordering_method(targetCls, index)
    or
    // 如果当前方法已实现，继续递归
    result = prefix and not exists(missing_ordering_method(targetCls, index)) and index < 5
    or
    // 如果前缀不为空，添加连接符和当前方法名
    prefix != "" and result = prefix + " or " + missing_ordering_method(targetCls, index)
  )
}

// 获取类声明的比较方法
Value get_declared_ordering_method(ClassValue targetCls, string methodName) {
  /* 仅当类自身声明了比较方法时才返回，避免将父类实现的方法归咎于当前类 */
  methodName = get_ordering_method_name(_) and result = targetCls.declaredAttribute(methodName)
}

// 查询未完整实现所有比较方法的类
from ClassValue targetCls, Value orderingMethod, string methodName
where
  not targetCls.failedInference(_) and // 确保类推理成功
  not uses_total_ordering(targetCls.getScope()) and // 排除使用total_ordering装饰器的类
  orderingMethod = get_declared_ordering_method(targetCls, methodName) and // 获取类声明的比较方法
  exists(missing_ordering_method(targetCls, _)) // 确保有未实现的比较方法
select targetCls,
  "Class " + targetCls.getName() + " implements $@, but does not implement " + // 报告类名和已实现的比较方法
    get_missing_methods_string(targetCls, 4) + ".", orderingMethod, methodName // 列出缺失的比较方法