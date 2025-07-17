# Requirements Document

## Introduction

This document outlines the requirements for an interactive Elixir learning application built with Phoenix LiveView. The application will provide a platform for users to learn Elixir and Phoenix LiveView through interactive lessons, where they can write and execute code directly in the browser. The application will evaluate the code against expected outputs to determine if the user has successfully completed each lesson. The application will support both Japanese and English languages to cater to a wider audience.

## Requirements

### Requirement 1: Interactive Code Execution

**User Story:** As a learner, I want to write and execute Elixir code directly in the browser, so that I can practice and experiment with Elixir concepts without setting up a local environment.

#### Acceptance Criteria

1. WHEN a user enters Elixir code in the code editor THEN the system SHALL execute the code and display the output.
2. WHEN the code execution results in an error THEN the system SHALL display the error message in a user-friendly format.
3. WHEN a user executes code THEN the system SHALL maintain the state of variables and functions defined in previous executions within the same lesson session.
4. WHEN a user executes code THEN the system SHALL have a timeout mechanism to prevent infinite loops or excessive resource consumption.
5. WHEN a user executes code THEN the system SHALL sanitize the input to prevent security vulnerabilities.

### Requirement 2: Structured Learning Path

**User Story:** As a learner, I want a structured series of lessons that progressively build on each other, so that I can learn Elixir and Phoenix LiveView in a logical sequence.

#### Acceptance Criteria

1. WHEN a user accesses the application THEN the system SHALL display a list of available lessons organized by difficulty level and topic.
2. WHEN a user selects a lesson THEN the system SHALL display the lesson content, including instructions, examples, and a code editor.
3. WHEN a user completes a lesson THEN the system SHALL mark it as completed and suggest the next lesson in the sequence.
4. WHEN a user returns to the application THEN the system SHALL remember their progress and allow them to continue from where they left off.
5. WHEN lessons are displayed THEN the system SHALL organize them into categories such as "Elixir Basics", "Pattern Matching", "Processes", "Phoenix LiveView", etc.

### Requirement 3: Lesson Evaluation

**User Story:** As a learner, I want immediate feedback on whether my code solution meets the lesson criteria, so that I can know if I've understood the concept correctly.

#### Acceptance Criteria

1. WHEN a user submits a solution THEN the system SHALL evaluate it against predefined criteria for that lesson.
2. WHEN a solution meets all criteria THEN the system SHALL mark the lesson as passed and provide positive feedback.
3. WHEN a solution does not meet all criteria THEN the system SHALL provide specific feedback on what aspects need improvement.
4. WHEN evaluating a solution THEN the system SHALL check both the output and, where relevant, the approach used in the code.
5. WHEN a lesson has multiple tasks THEN the system SHALL evaluate each task independently and provide feedback on each.

### Requirement 4: Multilingual Support

**User Story:** As a non-English speaking user, I want to access the learning content in my preferred language, so that I can learn more effectively.

#### Acceptance Criteria

1. WHEN a user accesses the application THEN the system SHALL detect their browser language preference and display content in that language if supported.
2. WHEN a user manually changes the language setting THEN the system SHALL immediately update all interface elements and lesson content to the selected language.
3. WHEN the application is launched THEN the system SHALL support at minimum both English and Japanese languages.
4. WHEN lesson content is displayed THEN the system SHALL ensure that code examples work consistently regardless of the selected language.
5. WHEN error messages or feedback are displayed THEN the system SHALL show them in the user's selected language.

### Requirement 5: Code Editor Features

**User Story:** As a learner, I want a feature-rich code editor that makes it easy to write Elixir code, so that I can focus on learning rather than fighting with the editor.

#### Acceptance Criteria

1. WHEN a user is writing code THEN the system SHALL provide syntax highlighting for Elixir code.
2. WHEN a user is writing code THEN the system SHALL provide basic auto-completion for common Elixir functions and keywords.
3. WHEN a user is writing code THEN the system SHALL provide proper indentation and formatting support.
4. WHEN a user wants to reset their code THEN the system SHALL provide an option to revert to the initial example or clear the editor.
5. WHEN a user is viewing lesson instructions alongside the code editor THEN the system SHALL allow resizing or collapsing the instruction panel to provide more space for coding when needed.

### Requirement 6: Lesson Content Management

**User Story:** As an administrator, I want to be able to add and update lesson content easily, so that the learning material can be kept current and expanded over time.

#### Acceptance Criteria

1. WHEN new Elixir versions are released THEN the system SHALL allow updating lesson content to reflect new language features or best practices.
2. WHEN lesson content needs to be modified THEN the system SHALL provide a structured format for defining lessons, including instructions, example code, and evaluation criteria.
3. WHEN creating a new lesson THEN the system SHALL support embedding code snippets, images, and formatted text in the lesson instructions.
4. WHEN defining lesson evaluation criteria THEN the system SHALL support multiple evaluation methods, such as output matching, function existence checking, and custom validators.
5. WHEN lessons are updated THEN the system SHALL maintain user progress and adapt it to the new content structure where possible.

### Requirement 7: User Interface and Experience

**User Story:** As a learner, I want an intuitive and responsive user interface, so that I can focus on learning without being distracted by usability issues.

#### Acceptance Criteria

1. WHEN a user accesses the application on different devices THEN the system SHALL provide a responsive design that works well on desktop and tablet devices.
2. WHEN a user is working through a lesson THEN the system SHALL provide clear visual indicators of their progress within the current lesson and overall course.
3. WHEN the application is processing code execution THEN the system SHALL display loading indicators to provide feedback during potentially lengthy operations.
4. WHEN a user completes a lesson successfully THEN the system SHALL provide a satisfying visual reward or acknowledgment.
5. WHEN a user is navigating between lessons THEN the system SHALL ensure that transitions are smooth and maintain the user's context.

### Requirement 8: Performance and Reliability

**User Story:** As a learner, I want the application to be fast and reliable, so that my learning experience is not interrupted by technical issues.

#### Acceptance Criteria

1. WHEN multiple users are using the application simultaneously THEN the system SHALL maintain responsive performance for all users.
2. WHEN a user executes code THEN the system SHALL isolate the execution environment to prevent interference between different users' code.
3. WHEN the application experiences an error THEN the system SHALL gracefully handle the error and provide meaningful feedback to the user.
4. WHEN a user's session is interrupted THEN the system SHALL attempt to recover their work when they return.
5. WHEN the system needs maintenance THEN the system SHALL provide advance notice to users when possible and minimize downtime.