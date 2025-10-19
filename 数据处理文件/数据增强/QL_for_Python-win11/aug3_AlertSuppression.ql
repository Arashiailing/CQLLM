/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// 导入CodeQL工具库中的AlertSuppression模块，重命名为AlertSuppression
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// 导入Python注释处理模块，重命名为PythonComment
private import semmle.python.Comment as PythonComment

// 定义节点包装类，继承自PythonComment::AstNode
class AstNode instanceof PythonComment::AstNode {
  // 获取节点位置信息的谓词
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 通过父类方法获取并验证位置信息
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 获取节点字符串表示
  string toString() { result = super.toString() }
}

// 定义单行注释包装类，继承自PythonComment::Comment
class SingleLineComment instanceof PythonComment::Comment {
  // 获取注释位置信息的谓词
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 通过父类方法获取并验证位置信息
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 获取注释文本内容
  string getText() { result = super.getContents() }

  // 获取注释字符串表示
  string toString() { result = super.toString() }
}

// 使用AlertSuppression模板建立节点与注释的抑制关系
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// 定义noqa抑制注释类，继承自SuppressionComment和SingleLineComment
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // 构造函数，验证noqa注释格式
  NoqaSuppressionComment() {
    // 检查注释文本是否符合noqa格式（不区分大小写）
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 获取注解标识符
  override string getAnnotation() { result = "lgtm" }

  // 定义注释覆盖的代码范围
  override predicate covers(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 验证注释位置并确保从行首开始
    this.hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }
}