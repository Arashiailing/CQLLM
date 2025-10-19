/**
 * @name Alert suppression
 * @description Provides detailed information about alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities for handling alert suppressions
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module for analyzing Python source code comments
private import semmle.python.Comment as P

/**
 * Represents a single-line comment in Python code with location tracking capabilities.
 * This class extends the base Comment class to provide location information and content access.
 */
class LineComment instanceof P::Comment {
  /**
   * Checks if this comment is located at the specified file coordinates.
   * @param sourceFilePath The path to the source file containing the comment
   * @param lineStart The starting line number of the comment
   * @param columnStart The starting column number of the comment
   * @param lineEnd The ending line number of the comment
   * @param columnEnd The ending column number of the comment
   */
  predicate hasLocationInfo(
    string sourceFilePath, int lineStart, int columnStart, int lineEnd, int columnEnd
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, lineStart, columnStart, lineEnd, columnEnd)
  }

  /**
   * Retrieves the text content of this comment.
   * @return The string content of the comment without any formatting
   */
  string getText() { result = super.getContents() }

  /**
   * Returns a string representation of this comment.
   * @return A descriptive string representing the comment
   */
  string toString() { result = super.toString() }
}

/**
 * Represents an AST node in Python code with location tracking capabilities.
 * This class extends the base AstNode class to provide location information for code elements.
 */
class CodeNode instanceof P::AstNode {
  /**
   * Checks if this AST node is located at the specified file coordinates.
   * @param sourceFilePath The path to the source file containing the node
   * @param lineStart The starting line number of the node
   * @param columnStart The starting column number of the node
   * @param lineEnd The ending line number of the node
   * @param columnEnd The ending column number of the node
   */
  predicate hasLocationInfo(
    string sourceFilePath, int lineStart, int columnStart, int lineEnd, int columnEnd
  ) {
    super.getLocation().hasLocationInfo(sourceFilePath, lineStart, columnStart, lineEnd, columnEnd)
  }

  /**
   * Returns a string representation of this AST node.
   * @return A descriptive string representing the AST node
   */
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template for CodeNode and LineComment
import AS::Make<CodeNode, LineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 * This class represents comments that follow the noqa convention for suppressing warnings.
 */
class NoqaStyleSuppression extends SuppressionComment instanceof LineComment {
  /**
   * Initializes a NoqaStyleSuppression by matching the noqa comment pattern.
   * The pattern matches comments that contain "noqa" (case-insensitive) optionally followed by additional content.
   */
  NoqaStyleSuppression() {
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Returns the suppression annotation identifier.
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines the code coverage scope for this suppression.
   * The suppression covers the entire line where the comment appears, starting from column 1.
   * @param sourceFilePath The path to the source file containing the suppression
   * @param lineStart The starting line number of the suppression coverage
   * @param columnStart The starting column number of the suppression coverage
   * @param lineEnd The ending line number of the suppression coverage
   * @param columnEnd The ending column number of the suppression coverage
   */
  override predicate covers(
    string sourceFilePath, int lineStart, int columnStart, int lineEnd, int columnEnd
  ) {
    // Match comment location and enforce line-start position
    this.hasLocationInfo(sourceFilePath, lineStart, _, lineEnd, columnEnd) and
    columnStart = 1
  }
}