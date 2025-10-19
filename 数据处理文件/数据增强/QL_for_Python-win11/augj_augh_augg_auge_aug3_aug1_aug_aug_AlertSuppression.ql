/**
 * @name Alert suppression
 * @description Provides information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import utilities for handling alert suppression mechanisms
private import codeql.util.suppression.AlertSuppression as SuppressionUtil
// Import utilities for processing Python comments
private import semmle.python.Comment as CommentProcessor

/**
 * Represents a single-line comment in Python code.
 * Inherits from CommentProcessor::Comment, providing access to location and content.
 */
class SingleLineComment instanceof CommentProcessor::Comment {
  /** Returns a string representation of the comment */
  string toString() { result = super.toString() }

  /**
   * Provides the location of the comment in the source code.
   * @param filePath - The path of the source file.
   * @param startLine - The starting line number.
   * @param startColumn - The starting column number.
   * @param endLine - The ending line number.
   * @param endColumn - The ending column number.
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate to the parent class's location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Gets the full text of the comment */
  string getText() { result = super.getContents() }
}

/**
 * Represents an AST node in Python code.
 * Inherits from CommentProcessor::AstNode, providing location and string representation.
 */
class PythonAstNode instanceof CommentProcessor::AstNode {
  /** Returns a string representation of the node */
  string toString() { result = super.toString() }

  /**
   * Provides the location of the node in the source code.
   * @param filePath - The path of the source file.
   * @param startLine - The starting line number.
   * @param startColumn - The starting column number.
   * @param endLine - The ending line number.
   * @param endColumn - The ending column number.
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Delegate to the parent class's location information
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }
}

// Apply template to generate suppression relationships between AST nodes and single-line comments
import SuppressionUtil::Make<PythonAstNode, SingleLineComment>

/**
 * Represents a noqa-style suppression comment compatible with Pylint and Pyflakes.
 * These comments are recognized by the LGTM analyzer for suppressing warnings.
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** Returns the annotation name used for identification */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Specifies the code range covered by this comment.
   * @param filePath - The path of the source file.
   * @param startLine - The starting line number.
   * @param startColumn - The starting column number.
   * @param endLine - The ending line number.
   * @param endColumn - The ending column number.
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // The comment must be at the beginning of the line and cover the entire line.
    startColumn = 1 and
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn)
  }

  /** Checks if the comment matches the noqa format (case-insensitive, with optional surrounding whitespace). */
  NoqaStyleSuppressor() {
    // The comment text must match the pattern: optional whitespace, then 'noqa', then optional non-colon characters.
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }
}