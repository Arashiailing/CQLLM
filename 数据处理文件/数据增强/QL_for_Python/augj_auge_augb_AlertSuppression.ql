/**
 * @name Alert suppression
 * @description Extracts and analyzes alert suppression annotations in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities with alias SuppressionToolkit
private import codeql.util.suppression.AlertSuppression as SuppressionToolkit
// Import Python comment processing utilities with alias CommentProcessor
private import semmle.python.Comment as CommentProcessor

// Define single-line comment representation extending Python's comment class
class SingleLineComment instanceof CommentProcessor::Comment {
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

// Define AST node representation extending Python's AST node
class CodeLocationNode instanceof CommentProcessor::AstNode {
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

// Establish alert suppression relationships using CodeQL's Make template
import SuppressionToolkit::Make<CodeLocationNode, SingleLineComment>

/**
 * Represents a noqa suppression annotation. Both pylint and pyflakes respect this annotation,
 * so LGTM analysis should also honor it.
 */
class NoqaAnnotation extends SuppressionComment instanceof SingleLineComment {
  // Initialize with comments matching noqa pattern (case-insensitive)
  NoqaAnnotation() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the annotation identifier for LGTM
  override string getAnnotation() { result = "lgtm" }

  // Determine code coverage of this suppression annotation
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Verify annotation location and ensure it starts at column 1 (line beginning)
    this.hasLocationInfo(sourceFile, beginLine, _, endLine, endCol) and
    beginCol = 1
  }
}