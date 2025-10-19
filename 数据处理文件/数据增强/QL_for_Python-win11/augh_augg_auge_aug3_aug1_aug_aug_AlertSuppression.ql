/**
 * @name Alert suppression
 * @description Generates information about alert suppressions in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import AlertSuppression utilities for handling warning suppression mechanisms
private import codeql.util.suppression.AlertSuppression as SuppressionUtil
// Import Python comment processing utilities for parsing and manipulating code comments
private import semmle.python.Comment as CommentProcessor

/**
 * Represents a single-line comment in Python code
 * Inherits from CommentProcessor::Comment, providing location and content access
 */
class SingleLineComment instanceof CommentProcessor::Comment {
  /** Generates a textual description of the comment */
  string toString() { result = super.toString() }

  /**
   * Provides detailed location information for the comment
   * @param filePath - Source file path
   * @param startLine - Starting line number
   * @param startColumn - Starting column number
   * @param endLine - Ending line number
   * @param endColumn - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Leverage parent class location information retrieval method
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }

  /** Retrieves the full text content of the comment */
  string getText() { result = super.getContents() }
}

/**
 * Represents an abstract syntax tree node in Python code
 * Inherits from CommentProcessor::AstNode, providing location and string representation
 */
class PythonAstNode instanceof CommentProcessor::AstNode {
  /** Generates a textual description of the node */
  string toString() { result = super.toString() }

  /**
   * Provides detailed location information for the node
   * @param filePath - Source file path
   * @param startLine - Starting line number
   * @param startColumn - Starting column number
   * @param endLine - Ending line number
   * @param endColumn - Ending column number
   */
  predicate hasLocationInfo(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Leverage parent class location information retrieval method
    super.getLocation().hasLocationInfo(filePath, startLine, startColumn, endLine, endColumn)
  }
}

// Apply template to generate suppression relationships between AST nodes and single-line comments
import SuppressionUtil::Make<PythonAstNode, SingleLineComment>

/**
 * Represents Pylint and Pyflakes compatible noqa-style suppression comments
 * These comments are recognized by LGTM analyzer for warning suppression
 */
class NoqaStyleSuppressor extends SuppressionComment instanceof SingleLineComment {
  /** Returns the annotation name used for identification */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Specifies the code range covered by the comment
   * @param filePath - Source file path
   * @param startLine - Starting line number
   * @param startColumn - Starting column number
   * @param endLine - Ending line number
   * @param endColumn - Ending column number
   */
  override predicate covers(
    string filePath, int startLine, int startColumn, int endLine, int endColumn
  ) {
    // Ensure comment is at line start and location information matches
    startColumn = 1 and
    this.hasLocationInfo(filePath, startLine, _, endLine, endColumn)
  }

  /** Validates comment compliance with noqa format specifications */
  NoqaStyleSuppressor() {
    // Check if comment content matches noqa format (case-insensitive, optional surrounding whitespace)
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }
}