/**
 * @name Alert suppression
 * @description Provides details about alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// 导入CodeQL工具库中的AlertSuppression模块，并命名为AS
private import codeql.util.suppression.AlertSuppression as AS
// 导入Python注释处理模块，并命名为P
private import semmle.python.Comment as P

// 表示Python抽象语法树节点的类，继承自P::AstNode
class PythonAstNode instanceof P::AstNode {
  // 检查节点是否具有特定位置信息的谓词
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 调用父类getLocation方法并验证位置信息匹配
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // 返回节点的字符串表示形式
  string toString() { result = super.toString() }
}

// 表示单行注释的类，继承自P::Comment
class PythonSingleLineComment instanceof P::Comment {
  // 检查注释是否具有特定位置信息的谓词
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 调用父类getLocation方法并验证位置信息匹配
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // 获取注释的文本内容
  string getText() { result = super.getContents() }

  // 返回注释的字符串表示形式
  string toString() { result = super.toString() }
}

// 使用AS::Make模板建立PythonAstNode和PythonSingleLineComment之间的抑制关系
import AS::Make<PythonAstNode, PythonSingleLineComment>

/**
 * 表示noqa抑制注释的类。pylint和pyflakes都支持此注释，因此lgtm也应支持。
 */
class PythonNoqaSuppression extends SuppressionComment instanceof PythonSingleLineComment {
  // 构造函数：验证注释文本是否符合noqa格式
  PythonNoqaSuppression() {
    // 使用正则表达式匹配noqa注释（不区分大小写）
    PythonSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 返回注解标识符
  override string getAnnotation() { result = "lgtm" }

  // 定义注释覆盖的代码范围
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // 验证注释位置信息并确保起始列为1（行首）
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}