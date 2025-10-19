/**
 * @name Alert suppression
 * @description Provides information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities, aliased as AS
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling utilities, aliased as CommentModule
private import semmle.python.Comment as CommentModule

// AST node representation extending Python's AST node
class AstNode instanceof CommentModule::AstNode {
  /**
   * Gets the location information for this AST node.
   * @param filePath - The path to the source file.
   * @param startLine - The starting line number.
   * @param startCol - The starting column number.
   * @param endLine - The ending line number.
   * @param endCol - The ending column number.
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location resolution to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // String representation of the AST node
  string toString() { result = super.toString() }
}

// Single-line comment representation extending Python's comment class
class SingleLineComment instanceof CommentModule::Comment {
  /**
   * Gets the location information for this comment.
   * @param filePath - The path to the source file.
   * @param startLine - The starting line number.
   * @param startCol - The starting column number.
   * @param endLine - The ending line number.
   * @param endCol - The ending column number.
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Delegate location resolution to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Extract text content from the comment
  string getText() { result = super.getContents() }

  // String representation of the comment
  string toString() { result = super.toString() }
}

// Establish alert suppression relationships using CodeQL's Make template
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a `noqa` suppression comment. Both pylint and pyflakes respect this annotation,
 * so LGTM analysis should also honor it.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize with comments matching noqa pattern (case-insensitive)
  NoqaSuppressionComment() {
    exists(string commentText |
      commentText = this.getText() and
      commentText.regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
    )
  }

  /**
   * Gets the annotation identifier for LGTM.
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Determines the code coverage of this suppression comment.
   * @param filePath - The path to the source file.
   * @param startLine - The starting line number.
   * @param startCol - The starting column number.
   * @param endLine - The ending line number.
   * @param endCol - The ending column number.
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Verify comment location and ensure it starts at column 1 (line beginning)
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}