/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities with alias AS
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling utilities with alias CommentModule
private import semmle.python.Comment as CommentModule

// Define AST node representation extending Python's AST node
class AstNode instanceof CommentModule::AstNode {
  /**
   * Retrieves location information for the AST node
   * @param filepath - Path to source file
   * @param startline - Starting line number
   * @param startcolumn - Starting column number
   * @param endline - Ending line number
   * @param endcolumn - Ending column number
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Delegate location resolution to parent class
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // Provide string representation of the AST node
  string toString() { result = super.toString() }
}

// Define single-line comment representation extending Python's comment class
class SingleLineComment instanceof CommentModule::Comment {
  /**
   * Retrieves location information for the comment
   * @param filepath - Path to source file
   * @param startline - Starting line number
   * @param startcolumn - Starting column number
   * @param endline - Ending line number
   * @param endcolumn - Ending column number
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Delegate location resolution to parent class
    super.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  // Extract text content from the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Establish alert suppression relationships using CodeQL's Make template
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this annotation,
 * so LGTM analysis should also honor it.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Initialize with comments matching noqa pattern (case-insensitive)
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the annotation identifier for LGTM
  override string getAnnotation() { result = "lgtm" }

  // Determine code coverage of this suppression comment
  override predicate covers(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // Verify comment location and ensure it starts at column 1 (line beginning)
    this.hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }
}