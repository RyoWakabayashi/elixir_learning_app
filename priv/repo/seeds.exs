# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirLearningApp.Repo.insert!(%ElixirLearningApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElixirLearningApp.Lessons
alias ElixirLearningApp.Lessons.Lesson

# Clear existing lessons
ElixirLearningApp.Repo.delete_all(Lesson)

# Create sample lessons
sample_lessons = [
  # Basics Category
  %{
    title: "Variables and Basic Types",
    slug: "variables-and-basic-types",
    description:
      "Learn about Elixir's basic data types including atoms, strings, numbers, and booleans.",
    category: "basics",
    difficulty: 1,
    order: 1,
    content:
      Lesson.build_content(
        [
          Lesson.text_section(
            "Welcome to your first Elixir lesson! In this lesson, you'll learn about variables and basic data types."
          ),
          Lesson.code_snippet_section("name = \"Alice\"\nage = 30\nis_student = false", "elixir",
            title: "Variable Assignment"
          ),
          Lesson.task_section(
            "Your Turn",
            "Create variables for your name, age, and whether you like programming."
          )
        ],
        objectives: ["Understand variable assignment", "Learn basic data types"],
        estimated_time: 15
      ),
    initial_code: "# Create your variables here\n",
    solution_code: "name = \"Your Name\"\nage = 25\nlikes_programming = true",
    evaluation_criteria: %{"type" => "variable_check", "variables" => ["name", "age"]}
  },
  %{
    title: "Functions and Pattern Matching",
    slug: "functions-and-pattern-matching",
    description: "Learn how to define functions and use pattern matching in Elixir.",
    category: "basics",
    difficulty: 2,
    order: 2,
    content:
      Lesson.build_content(
        [
          Lesson.text_section(
            "Functions are the building blocks of Elixir programs. Let's learn how to create them!"
          ),
          Lesson.code_snippet_section("def greet(name) do\n  \"Hello, \#{name}!\"\nend", "elixir",
            title: "Simple Function"
          ),
          Lesson.task_section(
            "Practice",
            "Write a function that takes two numbers and returns their sum."
          )
        ],
        objectives: ["Define functions", "Use pattern matching"],
        estimated_time: 20
      ),
    initial_code: "# Define your function here\n",
    solution_code: "def add(a, b) do\n  a + b\nend",
    evaluation_criteria: %{"type" => "function_check", "function" => "add", "arity" => 2}
  },

  # Pattern Matching Category
  %{
    title: "Basic Pattern Matching",
    slug: "basic-pattern-matching",
    description: "Introduction to pattern matching, one of Elixir's most powerful features.",
    category: "pattern_matching",
    difficulty: 2,
    order: 1,
    content:
      Lesson.build_content(
        [
          Lesson.text_section(
            "Pattern matching allows you to destructure data and match against specific patterns."
          ),
          Lesson.code_snippet_section(
            "{:ok, result} = {:ok, \"Success!\"}\n{x, y, z} = {1, 2, 3}",
            "elixir",
            title: "Pattern Matching Examples"
          ),
          Lesson.task_section("Try It", "Use pattern matching to extract values from a tuple.")
        ],
        objectives: ["Understand pattern matching", "Destructure tuples"],
        estimated_time: 25
      ),
    initial_code: "# Use pattern matching here\n",
    solution_code: "{first, second} = {\"hello\", \"world\"}",
    evaluation_criteria: %{"type" => "pattern_match", "expected" => "tuple_destructure"}
  },
  %{
    title: "Advanced Pattern Matching",
    slug: "advanced-pattern-matching",
    description: "Learn about guards, complex patterns, and pattern matching in function heads.",
    category: "pattern_matching",
    difficulty: 3,
    order: 2,
    content:
      Lesson.build_content(
        [
          Lesson.text_section(
            "Advanced pattern matching includes guards and matching in function definitions."
          ),
          Lesson.code_snippet_section(
            "def process({:ok, data}) when is_binary(data) do\n  \"Processing: \#{data}\"\nend",
            "elixir",
            title: "Function Pattern Matching"
          ),
          Lesson.task_section(
            "Challenge",
            "Write a function that pattern matches on different tuple formats."
          )
        ],
        objectives: ["Use guards", "Pattern match in functions"],
        estimated_time: 30
      ),
    initial_code: "# Write your pattern matching function here\n",
    solution_code:
      "def handle({:ok, msg}), do: \"Success: \#{msg}\"\ndef handle({:error, msg}), do: \"Error: \#{msg}\"",
    evaluation_criteria: %{
      "type" => "function_pattern_match",
      "patterns" => ["{:ok, _}", "{:error, _}"]
    }
  },

  # Processes Category
  %{
    title: "Introduction to Processes",
    slug: "introduction-to-processes",
    description: "Learn about Elixir's lightweight processes and the Actor model.",
    category: "processes",
    difficulty: 3,
    order: 1,
    content:
      Lesson.build_content(
        [
          Lesson.text_section(
            "Elixir processes are lightweight and isolated. They communicate via message passing."
          ),
          Lesson.code_snippet_section(
            "pid = spawn(fn -> IO.puts(\"Hello from process!\") end)",
            "elixir",
            title: "Spawning a Process"
          ),
          Lesson.task_section("Experiment", "Spawn a process that sends a message to itself.")
        ],
        objectives: ["Understand processes", "Spawn processes"],
        estimated_time: 35
      ),
    initial_code: "# Spawn your process here\n",
    solution_code: "spawn(fn -> send(self(), :hello) end)",
    evaluation_criteria: %{"type" => "process_spawn", "expected" => "spawn_call"}
  },
  %{
    title: "GenServer Basics",
    slug: "genserver-basics",
    description: "Learn about GenServer, OTP's generic server behavior.",
    category: "processes",
    difficulty: 4,
    order: 2,
    content:
      Lesson.build_content(
        [
          Lesson.text_section(
            "GenServer provides a standard way to build stateful server processes."
          ),
          Lesson.code_snippet_section(
            "defmodule Counter do\n  use GenServer\n  \n  def start_link(initial_value) do\n    GenServer.start_link(__MODULE__, initial_value)\n  end\nend",
            "elixir",
            title: "GenServer Module"
          ),
          Lesson.task_section("Build", "Create a simple GenServer that maintains a counter.")
        ],
        objectives: ["Understand GenServer", "Build stateful processes"],
        estimated_time: 45
      ),
    initial_code: "# Define your GenServer here\n",
    solution_code:
      "defmodule MyCounter do\n  use GenServer\n  \n  def start_link(initial) do\n    GenServer.start_link(__MODULE__, initial)\n  end\nend",
    evaluation_criteria: %{"type" => "genserver_check", "module" => "MyCounter"}
  },

  # Phoenix Category
  %{
    title: "LiveView Basics",
    slug: "liveview-basics",
    description: "Introduction to Phoenix LiveView for building interactive web applications.",
    category: "phoenix",
    difficulty: 3,
    order: 1,
    content:
      Lesson.build_content(
        [
          Lesson.text_section(
            "Phoenix LiveView enables rich, interactive web applications without writing JavaScript."
          ),
          Lesson.code_snippet_section(
            "defmodule MyAppWeb.CounterLive do\n  use Phoenix.LiveView\n  \n  def mount(_params, _session, socket) do\n    {:ok, assign(socket, count: 0)}\n  end\nend",
            "elixir",
            title: "LiveView Module"
          ),
          Lesson.task_section("Create", "Build a simple LiveView that displays a counter.")
        ],
        objectives: ["Understand LiveView", "Create interactive UIs"],
        estimated_time: 40
      ),
    initial_code: "# Create your LiveView here\n",
    solution_code:
      "defmodule MyLive do\n  use Phoenix.LiveView\n  \n  def mount(_, _, socket) do\n    {:ok, assign(socket, count: 0)}\n  end\nend",
    evaluation_criteria: %{"type" => "liveview_check", "module" => "MyLive"}
  }
]

# Insert sample lessons
Enum.each(sample_lessons, fn lesson_attrs ->
  case Lessons.create_lesson(lesson_attrs) do
    {:ok, lesson} ->
      IO.puts("Created lesson: #{lesson.title}")

    {:error, changeset} ->
      IO.puts("Failed to create lesson: #{inspect(changeset.errors)}")
  end
end)

IO.puts("Seeding completed!")
