/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities with alias SuppressionUtils
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import Python comment handling utilities with alias CommentHandler
private import semmle.python.Comment as CommentHandler

// Define AST node representation extending Python's AST node
class SourceNode instanceof CommentHandler::AstNode {
  /**
   * Retrieves location information for the AST node
   * @param sourceFile - Path to source file
   * @param beginLine - Starting line number
   * @param beginCol - Starting column number
   * @param endLine - Ending line number
   * @param endCol - Ending column number
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Delegate location resolution to parent class
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Provide string representation of the AST node
  string toString() { result = super.toString() }
}

// Define single-line comment representation extending Python's comment class
class LineComment instanceof CommentHandler::Comment {
  /**
   * Retrieves location information for the comment
   * @param sourceFile - Path to source file
   * @param beginLine - Starting line number
   * @param beginCol - Starting column number
   * @param endLine - Ending line number
   * @param endCol - Ending column number
   */
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Delegate location resolution to parent class
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, endLine, endCol)
  }

  // Extract text content from the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Establish alert suppression relationships using CodeQL's Make template
import SuppressionUtils::Make<SourceNode, LineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this annotation,
 * so LGTM analysis should also honor it.
 */
class NoqaSuppression extends SuppressionComment instanceof LineComment {
  // Initialize with comments matching noqa pattern (case-insensitive)
  NoqaSuppression() {
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the annotation identifier for LGTM
  override string getAnnotation() { result = "lgtm" }

  // Determine code coverage of this suppression comment
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Verify comment location and ensure it starts at column 1 (line beginning)
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}