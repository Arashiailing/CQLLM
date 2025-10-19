/**
 * @name Wrong number of arguments for format
 * @description A string formatting operation, such as '"%s: %s, %s" % (a,b)', where the number of conversion specifiers in the
 *              format string differs from the number of values to be formatted will raise a TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/percent-format/wrong-arguments
 */

import python
import semmle.python.strings

// 定义一个谓词函数，用于判断是否为字符串格式化操作
predicate string_format(BinaryExpr operation, StringLiteral str, Value args, AstNode origin) {
  // 检查操作符是否为取模运算符（%）
  operation.getOp() instanceof Mod and
  exists(Context ctx |
    // 检查左操作数是否指向给定的字符串字面量
    operation.getLeft().pointsTo(ctx, _, str) and
    // 检查右操作数是否指向给定的值
    operation.getRight().pointsTo(ctx, args, origin)
  )
}

// 计算序列的长度
int sequence_length(Value args) {
  /* Guess length of sequence */
  // 如果参数是一个元组，返回其元素个数
  exists(Tuple seq | seq.pointsTo(args, _) |
    result = strictcount(seq.getAnElt()) and
    // 确保不是星号表达式
    not seq.getAnElt() instanceof Starred
  )
  or
  // 如果参数是一个不可变字面量，长度为1
  exists(ImmutableLiteral i | i.getLiteralValue() = args | result = 1)
}

from
  BinaryExpr operation, StringLiteral fmt, Value args, int slen, int alen, AstNode origin,
  string provided
where
  // 检查是否为字符串格式化操作
  string_format(operation, fmt, args, origin) and
  // 获取参数序列的长度
  slen = sequence_length(args) and
  // 获取格式字符串中的项数
  alen = format_items(fmt) and
  // 比较序列长度和格式项数是否相等
  slen != alen and
  // 根据序列长度设置提示信息
  (if slen = 1 then provided = " is provided." else provided = " are provided.")
select operation,
  // 选择操作节点并生成错误信息
  "Wrong number of $@ for string format. Format $@ takes " + alen.toString() + ", but " +
    slen.toString() + provided, origin, "arguments", fmt, fmt.getText()
