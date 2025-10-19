/**
 * @name Alert suppression
 * @description Detects warning suppression mechanisms in Python code through comment analysis
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
  /**
   * Provides detailed location information for the comment
   * @param sourceFile - Source file path
   * @param lineStart - Starting line number
   * @param colStart - Starting column number
   * @param lineEnd - Ending line number
   * @param colEnd - Ending column number
   */
  predicate hasLocationInfo(
    string sourceFile, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    // Leverage parent class location information retrieval method
    super.getLocation().hasLocationInfo(sourceFile, lineStart, colStart, lineEnd, colEnd)
  }

  /** Generates a textual description of the comment */
  string toString() { result = super.toString() }

  /** Retrieves the full text content of the comment */
  string getText() { result = super.getContents() }
}

/**
 * Represents an abstract syntax tree node in Python code
 * Inherits from CommentProcessor::AstNode, providing location and string representation
 */
class PythonAstNode instanceof CommentProcessor::AstNode {
  /**
   * Provides detailed location information for the node
   * @param sourceFile - Source file path
   * @param lineStart - Starting line number
   * @param colStart - Starting column number
   * @param lineEnd - Ending line number
   * @param colEnd - Ending column number
   */
  predicate hasLocationInfo(
    string sourceFile, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    // Leverage parent class location information retrieval method
    super.getLocation().hasLocationInfo(sourceFile, lineStart, colStart, lineEnd, colEnd)
  }

  /** Generates a textual description of the node */
  string toString() { result = super.toString() }
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
   * @param sourceFile - Source file path
   * @param lineStart - Starting line number
   * @param colStart - Starting column number
   * @param lineEnd - Ending line number
   * @param colEnd - Ending column number
   */
  override predicate covers(
    string sourceFile, int lineStart, int colStart, int lineEnd, int colEnd
  ) {
    // Ensure comment is at line start and location information matches
    this.hasLocationInfo(sourceFile, lineStart, _, lineEnd, colEnd) and
    colStart = 1
  }

  /** Validates comment compliance with noqa format specifications */
  NoqaStyleSuppressor() {
    // Check if comment content matches noqa format (case-insensitive, optional surrounding whitespace)
    exists(string commentContent |
      commentContent = SingleLineComment.super.getText() and
      commentContent.regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
    )
  }
}