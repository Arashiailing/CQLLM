/**
 * @name Alert suppression
 * @description Identifies and processes alert suppressions in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import utilities for handling alert suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AlertSuppression
// Import utilities for processing Python comments
private import semmle.python.Comment as PythonComment

// AST node wrapper that extends PythonComment::AstNode functionality
class AstNode instanceof PythonComment::AstNode {
  /**
   * Retrieves location information for this AST node.
   * @param filePath - The file path containing the node
   * @param beginLine - Starting line number of the node
   * @param beginCol - Starting column number of the node
   * @param concludeLine - Ending line number of the node
   * @param concludeCol - Ending column number of the node
   */
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    // Forward location request to parent class implementation
    super.getLocation().hasLocationInfo(filePath, beginLine, beginCol, concludeLine, concludeCol)
  }

  /**
   * Provides a string representation of this AST node.
   * @returns Descriptive string representing the node
   */
  string toString() { result = super.toString() }
}

// Single-line comment wrapper extending PythonComment::Comment functionality
class SingleLineComment instanceof PythonComment::Comment {
  /**
   * Retrieves location information for this comment.
   * @param filePath - The file path containing the comment
   * @param beginLine - Starting line number of the comment
   * @param beginCol - Starting column number of the comment
   * @param concludeLine - Ending line number of the comment
   * @param concludeCol - Ending column number of the comment
   */
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    // Forward location request to parent class implementation
    super.getLocation().hasLocationInfo(filePath, beginLine, beginCol, concludeLine, concludeCol)
  }

  /**
   * Retrieves the textual content of this comment.
   * @returns String containing the comment text
   */
  string getText() { result = super.getContents() }

  /**
   * Provides a string representation of this comment.
   * @returns Descriptive string representing the comment
   */
  string toString() { result = super.toString() }
}

// Establish relationship between AST nodes and suppression comments
import AlertSuppression::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment, recognized by both pylint and pyflakes.
 * These suppressions should be respected by LGTM analysis.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  /**
   * Constructor that validates the noqa comment format.
   * The noqa keyword is case-insensitive and may include additional content.
   */
  NoqaSuppressionComment() {
    // Check if comment matches noqa pattern (case-insensitive)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the annotation identifier for this suppression.
   * @returns "lgtm" as the identifier for this annotation
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code range affected by this suppression.
   * @param filePath - The file path containing the comment
   * @param beginLine - Starting line of the affected range
   * @param beginCol - Starting column of the affected range
   * @param concludeLine - Ending line of the affected range
   * @param concludeCol - Ending column of the affected range
   */
  override predicate covers(
    string filePath, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    // Verify comment location and ensure it starts at the beginning of a line
    this.hasLocationInfo(filePath, beginLine, _, concludeLine, concludeCol) and
    beginCol = 1
  }
}