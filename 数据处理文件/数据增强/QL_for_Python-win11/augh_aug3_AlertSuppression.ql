/**
 * @name Alert suppression
 * @description Generates information about alert suppressions.
 * @kind alert-suppression
 * @id py/alert-suppression */

// 导入CodeQL工具库中的AlertSuppression模块，用于处理警报抑制功能
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// 导入Python注释处理模块，用于分析Python代码中的注释
private import semmle.python.Comment as PythonComment

/**
 * 包装类，表示Python注释中的抽象语法树节点
 * 提供位置信息和字符串表示功能
 */
class CommentNode instanceof PythonComment::AstNode {
  /**
   * 获取节点的位置信息
   * @param filepath 文件路径
   * @param startline 起始行号
   * @param startcolumn 起始列号
   * @param endline 结束行号
   * @param endcolumn 结束列号
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 调用父类的位置信息获取方法
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 返回节点的字符串表示形式
  string toString() { result = super.toString() }
}

/**
 * 包装类，表示Python中的单行注释
 * 继承自PythonComment::Comment，提供注释文本和位置信息
 */
class LineComment instanceof PythonComment::Comment {
  /**
   * 获取注释的位置信息
   * @param filepath 文件路径
   * @param startline 起始行号
   * @param startcolumn 起始列号
   * @param endline 结束行号
   * @param endcolumn 结束列号
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 调用父类的位置信息获取方法
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // 获取注释的文本内容
  string getText() { result = super.getContents() }

  // 返回注释的字符串表示形式
  string toString() { result = super.toString() }
}

// 使用AlertSuppression模板建立CommentNode和LineComment之间的抑制关系
import AlertSuppression::Make<CommentNode, LineComment>

/**
 * 表示noqa抑制注释的类
 * pylint和pyflakes都支持这种注释格式，因此lgtm也应该支持
 * 继承自SuppressionComment和LineComment
 */
class NoqaSuppressionComment extends SuppressionComment instanceof LineComment {
  /**
   * 构造函数，验证注释是否符合noqa格式
   * noqa注释格式：不区分大小写，以noqa开头，后面可以跟可选的冒号和内容
   */
  NoqaSuppressionComment() {
    // 使用正则表达式匹配noqa注释格式
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // 获取注解标识符，返回"lgtm"
  override string getAnnotation() { result = "lgtm" }

  /**
   * 定义注释覆盖的代码范围
   * @param filepath 文件路径
   * @param startline 起始行号
   * @param startcolumn 起始列号
   * @param endline 结束行号
   * @param endcolumn 结束列号
   */
  override predicate covers(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // 获取注释位置并确保从行首开始
    this.hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }
}