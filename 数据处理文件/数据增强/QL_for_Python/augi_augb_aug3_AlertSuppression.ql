/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// 导入告警抑制功能模块
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// 导入Python注释解析模块
private import semmle.python.Comment as PythonComment

// 代码节点包装类，封装PythonComment::AstNode
class CodeNode instanceof PythonComment::AstNode {
  // 获取节点位置信息的谓词
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 通过父类方法获取位置信息
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // 获取节点的字符串表示
  string toString() { result = super.toString() }
}

// 行注释包装类，封装PythonComment::Comment
class LineComment instanceof PythonComment::Comment {
  // 获取注释位置信息的谓词
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 通过父类方法获取位置信息
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // 获取注释的文本内容
  string getText() { result = super.getContents() }

  // 获取注释的字符串表示
  string toString() { result = super.toString() }
}

// 使用AlertSuppression模板建立节点与注释的抑制关系
import AlertSuppression::Make<CodeNode, LineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// noqa抑制注释类，继承自SuppressionComment和LineComment
class NoqaSuppressor extends SuppressionComment instanceof LineComment {
  // 构造函数，验证noqa注释格式
  NoqaSuppressor() {
    // 验证注释文本是否符合noqa格式（不区分大小写）
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 获取注解标识符
  override string getAnnotation() { result = "lgtm" }

  // 定义注释覆盖的代码范围
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 验证注释位置并确保从行首开始
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}