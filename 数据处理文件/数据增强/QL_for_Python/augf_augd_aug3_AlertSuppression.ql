/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import AlertSuppression utilities for handling suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// Import Python comment processing utilities
private import semmle.python.Comment as PythonComment

// AST node wrapper extending PythonComment::AstNode functionality
class AstNode instanceof PythonComment::AstNode {
  /**
   * Provides location details for this AST node.
   * @param file - Path to the file containing the node
   * @param startLine - Starting line number of the node
   * @param startCol - Starting column number of the node
   * @param endLine - Ending line number of the node
   * @param endCol - Ending column number of the node
   */
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  /**
   * Returns string representation of this AST node.
   * @returns Descriptive string for the node
   */
  string toString() { result = super.toString() }
}

// Single-line comment wrapper extending PythonComment::Comment functionality
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Provides location details for this comment.
   * @param file - Path to the file containing the comment
   * @param startLine - Starting line number of the comment
   * @param startCol - Starting column number of the comment
   * @param endLine - Ending line number of the comment
   * @param endCol - Ending column number of the comment
   */
  predicate hasLocationInfo(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(file, startLine, startCol, endLine, endCol)
  }

  /**
   * Returns the text content of this comment.
   * @returns String content of the comment
   */
  string getText() { result = super.getContents() }

  /**
   * Returns string representation of this comment.
   * @returns Descriptive string for the comment
   */
  string toString() { result = super.toString() }
}

// Establish alert suppression relationship between nodes and comments
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. Recognized by both pylint and pyflakes,
 * and should be respected by LGTM analysis.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructor validating noqa comment format.
   * The noqa keyword is case-insensitive and may include trailing content.
   */
  NoqaSuppressionComment() {
    // Validate comment matches noqa pattern (case-insensitive)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the annotation identifier for this suppression.
   * @returns "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range covered by this suppression.
   * @param file - Path to the file containing the comment
   * @param startLine - Starting line of the covered range
   * @param startCol - Starting column of the covered range
   * @param endLine - Ending line of the covered range
   * @param endCol - Ending column of the covered range
   */
  override predicate covers(
    string file, int startLine, int startCol, int endLine, int endCol
  ) {
    // Verify comment location and line-start positioning
    this.hasLocationInfo(file, startLine, _, endLine, endCol) and
    startCol = 1
  }
}