/**
 * @name Alert suppression
 * @description Identifies and processes alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities with alias AS
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling utilities with alias CommentModule
private import semmle.python.Comment as CommentModule

// Define Python AST node representation extending Python's AST node
class PyAstNode instanceof CommentModule::AstNode {
  /**
   * Extracts location details for the AST node
   * @param filePath - Source file path
   * @param startLine - Starting line number
   * @param startCol - Starting column number
   * @param endLine - Ending line number
   * @param endCol - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Forward location resolution to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Return string representation of the AST node
  string toString() { result = super.toString() }
}

// Define Python single-line comment representation extending Python's comment class
class PySingleLineComment instanceof CommentModule::Comment {
  /**
   * Extracts location details for the comment
   * @param filePath - Source file path
   * @param startLine - Starting line number
   * @param startCol - Starting column number
   * @param endLine - Ending line number
   * @param endCol - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Forward location resolution to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Retrieve the text content of the comment
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Establish alert suppression relationships using CodeQL's Make template
import AS::Make<PyAstNode, PySingleLineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this annotation,
 * so LGTM analysis should also honor it.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof PySingleLineComment {
  // Initialize with comments matching noqa pattern (case-insensitive)
  NoqaSuppressionComment() {
    // Match comments starting with optional whitespace, followed by 'noqa' (case-insensitive),
    // optionally followed by non-colon characters
    PySingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the annotation identifier for LGTM
  override string getAnnotation() { result = "lgtm" }

  // Determine code coverage of this suppression comment
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Verify comment location and ensure it starts at column 1 (line beginning)
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}