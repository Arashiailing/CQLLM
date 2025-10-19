/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// 导入CodeQL工具库中的AlertSuppression模块，用于处理警报抑制功能
private import codeql.util.suppression.AlertSuppression as AS
// 导入Python注释处理模块，用于分析和处理Python代码中的注释
private import semmle.python.Comment as PyComments

// 定义代码节点类，封装Python AST节点的基本功能
class CodeNode instanceof PyComments::AstNode {
  // 验证节点是否具有指定的位置信息
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // 检查节点的位置信息是否与提供的参数匹配
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // 获取节点的字符串表示形式
  string toString() { result = super.toString() }
}

// 定义单行注释类，封装Python代码中的单行注释功能
class InlineComment instanceof PyComments::Comment {
  // 验证注释是否具有指定的位置信息
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // 检查注释的位置信息是否与提供的参数匹配
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // 获取注释的文本内容
  string getText() { result = super.getContents() }

  // 获取注释的字符串表示形式
  string toString() { result = super.toString() }
}

// 应用AlertSuppression模板，建立代码节点与注释之间的抑制关系
import AS::Make<CodeNode, InlineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// 定义noqa抑制注释类，用于识别和处理Python代码中的noqa抑制注释
class NoqaSuppressionComment extends SuppressionComment instanceof InlineComment {
  // 构造函数：验证注释是否符合noqa格式规范
  NoqaSuppressionComment() {
    // 检查注释文本是否匹配noqa模式（不区分大小写）
    // 正则表达式匹配以任意空白开头，后跟"noqa"（不区分大小写），后面可以跟着非冒号的字符或什么也不跟
    InlineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 返回注解标识符，用于标识特定的抑制类型
  override string getAnnotation() { result = "lgtm" }

  // 定义注释所覆盖的代码范围
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // 确保注释位于行首（起始列为1）并验证位置信息
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}