/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// 导入CodeQL工具库中的AlertSuppression模块，并命名为AS
private import codeql.util.suppression.AlertSuppression as AS
// 导入Python注释处理模块，并命名为P
private import semmle.python.Comment as P

// 定义一个名为AstNode的类，继承自P::AstNode
class AstNode instanceof P::AstNode {
  // 定义一个谓词hasLocationInfo，用于检查节点是否具有特定的位置信息
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 调用父类的getLocation方法，并检查位置信息是否匹配
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 重写toString方法，返回节点的字符串表示
  string toString() { result = super.toString() }
}

// 定义一个名为SingleLineComment的类，继承自P::Comment
class SingleLineComment instanceof P::Comment {
  // 定义一个谓词hasLocationInfo，用于检查注释是否具有特定的位置信息
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 调用父类的getLocation方法，并检查位置信息是否匹配
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 定义一个getText方法，返回注释的文本内容
  string getText() { result = super.getContents() }

  // 重写toString方法，返回注释的字符串表示
  string toString() { result = super.toString() }
}

// 使用AS::Make模板生成AstNode和SingleLineComment之间的抑制关系
import AS::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// 定义一个名为NoqaSuppressionComment的类，继承自SingleLineComment和SuppressionComment
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // 构造函数，初始化时检查注释文本是否符合noqa格式
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 重写getAnnotation方法，返回注解标识符"lgtm"
  override string getAnnotation() { result = "lgtm" }

  // 重写covers谓词，定义该注释覆盖的代码范围
  override predicate covers(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 检查注释的位置信息，并确保起始列为1（即行首）
    this.hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }
}
