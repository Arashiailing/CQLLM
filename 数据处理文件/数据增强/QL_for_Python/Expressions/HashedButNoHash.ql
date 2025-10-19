/**
 * @name Unhashable object hashed
 * @description Hashing an object which is not hashable will result in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/hash-unhashable-value
 */

import python

/*
 * This assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * For sequences, the index must be an int, which are hashable, so we don't need to treat them specially.
 * For numpy arrays, the index may be a list, which are not hashable and needs to be treated specially.
 */

// 判断一个类是否为numpy数组类型
predicate numpy_array_type(ClassValue na) {
  exists(ModuleValue np | np.getName() = "numpy" or np.getName() = "numpy.core" |
    na.getASuperType() = np.attr("ndarray")
  )
}

// 判断一个值是否有自定义的__getitem__方法
predicate has_custom_getitem(Value v) {
  v.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(v.getClass())
}

// 判断一个控制流节点是否被显式地哈希过
predicate explicitly_hashed(ControlFlowNode f) {
  exists(CallNode c, GlobalVariable hash |
    c.getArg(0) = f and c.getFunction().(NameNode).uses(hash) and hash.getId() = "hash"
  )
}

// 判断一个下标操作是否涉及不可哈希的对象
predicate unhashable_subscript(ControlFlowNode f, ClassValue c, ControlFlowNode origin) {
  is_unhashable(f, c, origin) and
  exists(SubscriptNode sub | sub.getIndex() = f |
    exists(Value custom_getitem |
      sub.getObject().pointsTo(custom_getitem) and
      not has_custom_getitem(custom_getitem)
    )
  )
}

// 判断一个对象是否是不可哈希的
predicate is_unhashable(ControlFlowNode f, ClassValue cls, ControlFlowNode origin) {
  exists(Value v | f.pointsTo(v, origin) and v.getClass() = cls |
    not cls.hasAttribute("__hash__") and not cls.failedInference(_) and cls.isNewStyle()
    or
    cls.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Holds if `f` is inside a `try` that catches `TypeError`. For example:
 *
 *    try:
 *       ... f ...
 *    except TypeError:
 *       ...
 *
 * This predicate is used to eliminate false positive results. If `hash`
 * is called on an unhashable object then a `TypeError` will be thrown.
 * But this is not a bug if the code catches the `TypeError` and handles
 * it.
 */
// 判断一个控制流节点是否在捕获TypeError的try块中
predicate typeerror_is_caught(ControlFlowNode f) {
  exists(Try try |
    try.getBody().contains(f.getNode()) and
    try.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// 查询未捕获的、对不可哈希对象的哈希操作或下标操作
from ControlFlowNode f, ClassValue c, ControlFlowNode origin
where
  not typeerror_is_caught(f) and
  (
    explicitly_hashed(f) and is_unhashable(f, c, origin)
    or
    unhashable_subscript(f, c, origin)
  )
select f.getNode(), "This $@ of $@ is unhashable.", origin, "instance", c, c.getQualifiedName()
