/**
 * @name Alert suppression
 * @description Provides detailed analysis of alert suppression features in Python source code.
 * This query enables detection and handling of alert suppression annotations in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import utilities for managing alert suppression functionality
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import tools for processing Python code comments
private import semmle.python.Comment as PythonComment

/**
 * Represents comments that span a single line with accurate location data.
 * This class wraps the `PythonComment::Comment` to provide location and text content.
 */
class OneLineComment instanceof PythonComment::Comment {
  /**
   * Verifies if the comment matches the provided location information.
   * @param sourceFile The source file containing the comment.
   * @param beginLine The starting line of the comment.
   * @param beginCol The starting column of the comment.
   * @param concludeLine The ending line of the comment.
   * @param concludeCol The ending column of the comment.
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, concludeLine, concludeCol)
  }

  /**
   * Extracts the text content from the comment.
   */
  string getText() { result = super.getContents() }

  /**
   * Generates a text representation of the comment.
   */
  string toString() { result = super.toString() }
}

/**
 * Represents code structure elements with advanced location tracking.
 * This class wraps the `PythonComment::AstNode` to provide location information.
 */
class CodeNode instanceof PythonComment::AstNode {
  /**
   * Determines if the node matches the specified location parameters.
   * @param sourceFile The source file containing the node.
   * @param beginLine The starting line of the node.
   * @param beginCol The starting column of the node.
   * @param concludeLine The ending line of the node.
   * @param concludeCol The ending column of the node.
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, concludeLine, concludeCol)
  }

  /**
   * Generates a text representation of the code node.
   */
  string toString() { result = super.toString() }
}

// Apply the suppression relationship creation pattern using the SuppressionUtils template
import SuppressionUtils::Make<CodeNode, OneLineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * This class identifies comments that follow the noqa suppression convention.
 */
class NoqaIgnoreComment extends SuppressionComment instanceof OneLineComment {
  /**
   * Constructor that identifies noqa comment formats.
   * The comment must match the pattern: optional whitespace, "noqa", optional whitespace, and optional non-colon content.
   */
  NoqaIgnoreComment() {
    OneLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the identifier for this suppression annotation.
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the scope covered by this suppression annotation.
   * The suppression covers the entire line where the comment appears, starting from the first column.
   * @param sourceFile The source file containing the suppression.
   * @param beginLine The starting line of the suppression scope (same as the comment line).
   * @param beginCol The starting column of the suppression scope (always 1).
   * @param concludeLine The ending line of the suppression scope (same as the comment line).
   * @param concludeCol The ending column of the suppression scope (same as the comment's ending column).
   */
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    // The suppression covers the entire line where the comment is located, starting at column 1.
    this.hasLocationInfo(sourceFile, beginLine, _, concludeLine, concludeCol) and
    beginCol = 1
  }
}