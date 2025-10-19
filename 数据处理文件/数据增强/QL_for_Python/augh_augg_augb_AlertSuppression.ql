/**
 * @name Alert suppression detection
 * @description Detects and analyzes alert suppression annotations in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression framework with alias SuppressionFramework
private import codeql.util.suppression.AlertSuppression as SuppressionFramework
// Import Python comment analysis utilities with alias CommentUtils
private import semmle.python.Comment as CommentUtils

// Define a specialized representation for single-line comments in Python code
class SingleLineComment instanceof CommentUtils::Comment {
  /**
   * Extracts precise location details for the comment
   * @param sourceFilePath - Absolute path to the source file
   * @param lineNumberStart - Starting line number (1-based)
   * @param columnNumberStart - Starting column number (1-based)
   * @param lineNumberEnd - Ending line number (1-based)
   * @param columnNumberEnd - Ending column number (1-based)
   */
  predicate hasLocationInfo(
    string sourceFilePath, int lineNumberStart, int columnNumberStart, 
    int lineNumberEnd, int columnNumberEnd
  ) {
    // Delegate location information retrieval to the parent class
    super.getLocation().hasLocationInfo(sourceFilePath, lineNumberStart, columnNumberStart, lineNumberEnd, columnNumberEnd)
  }

  // Retrieve the actual text content of the comment
  string getText() { result = super.getContents() }

  // Provide a descriptive string representation of the comment
  string toString() { result = super.toString() }
}

// Define a specialized representation for AST nodes in Python code
class AstNode instanceof CommentUtils::AstNode {
  /**
   * Extracts precise location details for the AST node
   * @param sourceFilePath - Absolute path to the source file
   * @param lineNumberStart - Starting line number (1-based)
   * @param columnNumberStart - Starting column number (1-based)
   * @param lineNumberEnd - Ending line number (1-based)
   * @param columnNumberEnd - Ending column number (1-based)
   */
  predicate hasLocationInfo(
    string sourceFilePath, int lineNumberStart, int columnNumberStart, 
    int lineNumberEnd, int columnNumberEnd
  ) {
    // Delegate location information retrieval to the parent class
    super.getLocation().hasLocationInfo(sourceFilePath, lineNumberStart, columnNumberStart, lineNumberEnd, columnNumberEnd)
  }

  // Provide a descriptive string representation of the AST node
  string toString() { result = super.toString() }
}

// Establish the alert suppression relationship using CodeQL's Make template
import SuppressionFramework::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. Both pylint and pyflakes respect this annotation,
 * so LGTM analysis should also honor it.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor: identifies comments matching the noqa pattern (case-insensitive)
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Returns the annotation identifier recognized by LGTM
  override string getAnnotation() { result = "lgtm" }

  // Determines the code coverage scope of this suppression comment
  override predicate covers(
    string sourceFilePath, int lineNumberStart, int columnNumberStart, 
    int lineNumberEnd, int columnNumberEnd
  ) {
    // Verify comment location and ensure it starts at column 1 (beginning of line)
    this.hasLocationInfo(sourceFilePath, lineNumberStart, _, lineNumberEnd, columnNumberEnd) and
    columnNumberStart = 1
  }
}