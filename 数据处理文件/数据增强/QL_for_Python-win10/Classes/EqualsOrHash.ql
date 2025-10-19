/**
 * @name Inconsistent equality and hashing
 * @description Defining equality for a class without also defining hashability (or vice-versa) violates the object model.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-581
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/equals-hash-mismatch
 */

import python

// 定义一个函数，用于检查类是否定义了相等性比较方法（__eq__或__cmp__）
CallableValue defines_equality(ClassValue c, string name) {
  // 如果名称是"__eq__"或者在Python 2中是"__cmp__"，则返回该属性
  (
    name = "__eq__"
    or
    major_version() = 2 and name = "__cmp__"
  ) and
  result = c.declaredAttribute(name)
}

// 定义一个函数，用于检查类是否实现了指定的方法
CallableValue implemented_method(ClassValue c, string name) {
  // 如果类定义了相等性比较方法，或者定义了__hash__方法且名称为"__hash__"，则返回该属性
  result = defines_equality(c, name)
  or
  result = c.declaredAttribute("__hash__") and name = "__hash__"
}

// 定义一个函数，用于检查类是否未实现某些方法
string unimplemented_method(ClassValue c) {
  // 如果类没有定义相等性比较方法，并且根据Python版本返回相应的未实现方法名
  not exists(defines_equality(c, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  /* Python 3 automatically makes classes unhashable if __eq__ is defined, but __hash__ is not */
  // 如果类没有声明__hash__方法，并且是在Python 2中，则返回"__hash__"
  not c.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Holds if this class is unhashable */
// 定义一个谓词，用于判断类是否不可哈希化
predicate unhashable(ClassValue cls) {
  // 如果类的__hash__方法被设置为None，或者该方法从不返回值，则认为类是不可哈希化的
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// 定义一个谓词，用于判断类是否违反了哈希契约
predicate violates_hash_contract(ClassValue c, string present, string missing, Value method) {
  // 如果类不是不可哈希化的，并且缺少某些方法，同时存在已实现的方法，并且没有失败的推断，则认为违反了哈希契约
  not unhashable(c) and
  missing = unimplemented_method(c) and
  method = implemented_method(c, present) and
  not c.failedInference(_)
}

// 从类中选择违反哈希契约的方法，并输出相关信息
from ClassValue c, string present, string missing, CallableValue method
where
  violates_hash_contract(c, present, missing, method) and
  exists(c.getScope()) // Suppress results that aren't from source
select method, "Class $@ implements " + present + " but does not define " + missing + ".", c,
  c.getName()
