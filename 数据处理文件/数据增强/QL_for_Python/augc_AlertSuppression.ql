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

// 定义代码节点类，继承自Python AST节点
class CodeNode instanceof P::AstNode {
  // 检查节点是否具有特定位置信息
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 验证节点位置信息是否匹配指定参数
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 返回节点的字符串表示形式
  string toString() { result = super.toString() }
}

// 定义单行注释类，继承自Python注释
class InlineComment instanceof P::Comment {
  // 检查注释是否具有特定位置信息
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 验证注释位置信息是否匹配指定参数
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 获取注释文本内容
  string getText() { result = super.getContents() }

  // 返回注释的字符串表示形式
  string toString() { result = super.toString() }
}

// 使用AS::Make模板建立代码节点和注释间的抑制关系
import AS::Make<CodeNode, InlineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// 定义noqa抑制注释类，继承自抑制注释和单行注释
class NoqaSuppressionComment extends SuppressionComment instanceof InlineComment {
  // 构造函数：验证注释是否符合noqa格式
  NoqaSuppressionComment() {
    // 检查注释文本是否匹配noqa模式（不区分大小写）
    InlineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 返回注解标识符
  override string getAnnotation() { result = "lgtm" }

  // 定义注释覆盖的代码范围
  override predicate covers(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 确保注释位于行首（起始列为1）并验证位置信息
    this.hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }
}