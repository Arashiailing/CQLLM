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

// 判断类是否使用了total_ordering装饰器
predicate total_ordering(Class cls) {
  exists(Attribute a | a = cls.getADecorator() | a.getName() = "total_ordering") // 检查是否有名为total_ordering的装饰器属性
  or
  exists(Name n | n = cls.getADecorator() | n.getId() = "total_ordering") // 检查是否有名为total_ordering的装饰器名称
}

// 根据序号返回对应的比较方法名称
string ordering_name(int n) {
  result = "__lt__" and n = 1 // 如果序号为1，返回"__lt__"
  or
  result = "__le__" and n = 2 // 如果序号为2，返回"__le__"
  or
  result = "__gt__" and n = 3 // 如果序号为3，返回"__gt__"
  or
  result = "__ge__" and n = 4 // 如果序号为4，返回"__ge__"
}

// 判断类或其超类是否重写了指定的比较方法
predicate overrides_ordering_method(ClassValue c, string name) {
  name = ordering_name(_) and ( // 检查name是否是有效的比较方法名称
    c.declaresAttribute(name) // 检查类是否声明了该比较方法
    or
    exists(ClassValue sup | sup = c.getASuperType() and not sup = Value::named("object") | // 检查类的超类（不包括object）是否声明了该比较方法
      sup.declaresAttribute(name)
    )
  )
}

// 获取类未实现的比较方法名称
string unimplemented_ordering(ClassValue c, int n) {
  not c = Value::named("object") and // 确保类不是object
  not overrides_ordering_method(c, result) and // 确保类及其超类没有实现该方法
  result = ordering_name(n) // 获取对应序号的比较方法名称
}

// 获取类未实现的所有比较方法名称，以字符串形式返回
string unimplemented_ordering_methods(ClassValue c, int n) {
  n = 0 and result = "" and exists(unimplemented_ordering(c, _)) // 初始化结果字符串并检查是否存在未实现的方法
  or
  exists(string prefix, int nm1 | n = nm1 + 1 and prefix = unimplemented_ordering_methods(c, nm1) | // 递归构建结果字符串
    prefix = "" and result = unimplemented_ordering(c, n) // 如果前缀为空，直接添加当前方法名称
    or
    result = prefix and not exists(unimplemented_ordering(c, n)) and n < 5 // 如果当前方法已实现，继续递归
    or
    prefix != "" and result = prefix + " or " + unimplemented_ordering(c, n) // 如果前缀不为空，添加“or”连接符和当前方法名称
  )
}

// 获取类声明的比较方法（如果存在）
Value ordering_method(ClassValue c, string name) {
  /* If class doesn't declare a method then don't blame this class (the superclass will be blamed). */
  name = ordering_name(_) and result = c.declaredAttribute(name) // 如果类声明了该比较方法，则返回该方法
}

// 查询未完整实现所有比较方法的类，并报告缺失的方法
from ClassValue c, Value ordering, string name
where
  not c.failedInference(_) and // 确保类没有推理失败
  not total_ordering(c.getScope()) and // 确保类没有使用total_ordering装饰器
  ordering = ordering_method(c, name) and // 获取类声明的比较方法
  exists(unimplemented_ordering(c, _)) // 确保类有未实现的比较方法
select c,
  "Class " + c.getName() + " implements $@, but does not implement " + // 报告类名和已实现但未完全实现的比较方法
    unimplemented_ordering_methods(c, 4) + ".", ordering, name // 列出缺失的比较方法名称
