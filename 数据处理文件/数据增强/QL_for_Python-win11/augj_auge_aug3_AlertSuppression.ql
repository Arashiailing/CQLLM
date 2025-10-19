/**
 * @name Alert suppression
 * @description Identifies and processes alert suppressions in Python code using noqa comments.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Core imports for alert suppression and Python comment handling
private import codeql.util.suppression.AlertSuppression as AlertSuppression
private import semmle.python.Comment as PythonComment

/**
 * Enhanced wrapper for Python AST nodes providing location and string representation.
 */
class CodeNode instanceof PythonComment::AstNode {
  /**
   * Retrieves location details for the AST node.
   * @param filePath Path of the containing file
   * @param startLine Starting line number
   * @param startCol Starting column number
   * @param endLine Ending line number
   * @param endCol Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Returns string representation of the AST node */
  string toString() { result = super.toString() }
}

/**
 * Enhanced wrapper for Python single-line comments with location and text access.
 */
class LineComment instanceof PythonComment::Comment {
  /**
   * Retrieves location details for the comment.
   * @param filePath Path of the containing file
   * @param startLine Starting line number
   * @param startCol Starting column number
   * @param endLine Ending line number
   * @param endCol Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  /** Returns the text content of the comment */
  string getText() { result = super.getContents() }

  /** Returns string representation of the comment */
  string toString() { result = super.toString() }
}

// Establish alert suppression relationship using imported template
import AlertSuppression::Make<CodeNode, LineComment>

/**
 * Represents noqa suppression comments recognized by Python linters.
 * Extends suppression handling for LGTM compatibility.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof LineComment {
  NoqaSuppressionComment() {
    // Match noqa pattern (case-insensitive with optional content)
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /** Returns LGTM-specific annotation identifier */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Defines code coverage scope for the suppression.
   * @param filePath Path of the containing file
   * @param startLine Starting line number
   * @param startCol Starting column number
   * @param endLine Ending line number
   * @param endCol Ending column number
   */
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure comment starts at line beginning and matches location
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}