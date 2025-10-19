/**
 * @name Alert suppression detection
 * @description Identifies and analyzes alert suppression annotations in Python source code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression framework with alias SuppressionFramework
private import codeql.util.suppression.AlertSuppression as SuppressionFramework
// Import Python comment analysis utilities with alias CommentUtils
private import semmle.python.Comment as CommentUtils

// Specialized representation for Python single-line comments
class SingleLineComment instanceof CommentUtils::Comment {
  /**
   * Retrieves precise location details for the comment
   * @param filePath - Absolute path to source file
   * @param startLine - Starting line number (1-based)
   * @param startColumn - Starting column number (1-based)
   * @param endLine - Ending line number (1-based)
   * @param endColumn - Ending column number (1-based)
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, 
    int endLine, int endColumn
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Extract the comment's text content
  string getText() { result = super.getContents() }

  // Provide descriptive representation of the comment
  string toString() { result = super.toString() }
}

// Specialized representation for Python AST nodes
class AstNode instanceof CommentUtils::AstNode {
  /**
   * Retrieves precise location details for the AST node
   * @param filePath - Absolute path to source file
   * @param startLine - Starting line number (1-based)
   * @param startColumn - Starting column number (1-based)
   * @param endLine - Ending line number (1-based)
   * @param endColumn - Ending column number (1-based)
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, 
    int endLine, int endColumn
  ) {
    // Delegate location retrieval to parent class
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  // Provide descriptive representation of the AST node
  string toString() { result = super.toString() }
}

// Establish alert suppression relationship using CodeQL's Make template
import SuppressionFramework::Make<AstNode, SingleLineComment>

/**
 * Represents noqa suppression comments. Both pylint and pyflakes respect this annotation,
 * so LGTM analysis should also honor it.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor: identifies comments matching noqa pattern (case-insensitive)
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Returns the annotation identifier recognized by LGTM
  override string getAnnotation() { result = "lgtm" }

  // Determines the code coverage scope of this suppression comment
  override predicate covers(
    string filePath, int startLine, int startColumn, 
    int endLine, int endColumn
  ) {
    // Verify comment location and ensure line-start positioning
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn) and
    startColumn = 1
  }
}