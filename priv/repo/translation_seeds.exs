# Script for adding sample translations to lessons
#
# Run with: mix run priv/repo/translation_seeds.exs

alias ElixirLearningApp.Lessons

# Sample Japanese translations for existing lessons
translations = [
  {
    "variables-and-basic-types",
    %{
      "title" => "変数と基本型",
      "description" => "アトム、文字列、数値、ブール値などのElixirの基本データ型について学びます。",
      "content" => %{
        "objectives" => ["変数の代入を理解する", "基本データ型を学ぶ"],
        "sections" => [
          %{
            "content" => "最初のElixirレッスンへようこそ！このレッスンでは、変数と基本データ型について学びます。"
          },
          %{
            "title" => "変数の代入"
          },
          %{
            "title" => "あなたの番",
            "description" => "あなたの名前、年齢、プログラミングが好きかどうかの変数を作成してください。"
          }
        ]
      }
    }
  },
  {
    "functions-and-pattern-matching",
    %{
      "title" => "関数とパターンマッチング",
      "description" => "Elixirで関数を定義し、パターンマッチングを使用する方法を学びます。",
      "content" => %{
        "objectives" => ["関数を定義する", "パターンマッチングを使用する"],
        "sections" => [
          %{
            "content" => "関数はElixirプログラムの構成要素です。作成方法を学びましょう！"
          },
          %{
            "title" => "シンプルな関数"
          },
          %{
            "title" => "練習",
            "description" => "2つの数値を受け取り、その合計を返す関数を書いてください。"
          }
        ]
      }
    }
  },
  {
    "basic-pattern-matching",
    %{
      "title" => "基本的なパターンマッチング",
      "description" => "Elixirの最も強力な機能の一つであるパターンマッチングの紹介。",
      "content" => %{
        "objectives" => ["パターンマッチングを理解する", "タプルを分解する"],
        "sections" => [
          %{
            "content" => "パターンマッチングを使用すると、データを分解し、特定のパターンに対してマッチングできます。"
          },
          %{
            "title" => "パターンマッチングの例"
          },
          %{
            "title" => "試してみよう",
            "description" => "パターンマッチングを使用してタプルから値を抽出してください。"
          }
        ]
      }
    }
  },
  {
    "advanced-pattern-matching",
    %{
      "title" => "高度なパターンマッチング",
      "description" => "ガード、複雑なパターン、関数ヘッドでのパターンマッチングについて学びます。",
      "content" => %{
        "objectives" => ["ガードを使用する", "関数でパターンマッチングする"],
        "sections" => [
          %{
            "content" => "高度なパターンマッチングには、ガードと関数定義でのマッチングが含まれます。"
          },
          %{
            "title" => "関数パターンマッチング"
          },
          %{
            "title" => "チャレンジ",
            "description" => "異なるタプル形式でパターンマッチングする関数を書いてください。"
          }
        ]
      }
    }
  },
  {
    "introduction-to-processes",
    %{
      "title" => "プロセス入門",
      "description" => "Elixirの軽量プロセスとアクターモデルについて学びます。",
      "content" => %{
        "objectives" => ["プロセスを理解する", "プロセスを生成する"],
        "sections" => [
          %{
            "content" => "Elixirプロセスは軽量で分離されています。メッセージパッシングを通じて通信します。"
          },
          %{
            "title" => "プロセスの生成"
          },
          %{
            "title" => "実験",
            "description" => "自分自身にメッセージを送信するプロセスを生成してください。"
          }
        ]
      }
    }
  },
  {
    "genserver-basics",
    %{
      "title" => "GenServer基礎",
      "description" => "OTPの汎用サーバー動作であるGenServerについて学びます。",
      "content" => %{
        "objectives" => ["GenServerを理解する", "ステートフルプロセスを構築する"],
        "sections" => [
          %{
            "content" => "GenServerは、ステートフルサーバープロセスを構築するための標準的な方法を提供します。"
          },
          %{
            "title" => "GenServerモジュール"
          },
          %{
            "title" => "構築",
            "description" => "カウンターを維持するシンプルなGenServerを作成してください。"
          }
        ]
      }
    }
  },
  {
    "liveview-basics",
    %{
      "title" => "LiveView基礎",
      "description" => "インタラクティブなWebアプリケーションを構築するためのPhoenix LiveViewの紹介。",
      "content" => %{
        "objectives" => ["LiveViewを理解する", "インタラクティブなUIを作成する"],
        "sections" => [
          %{
            "content" => "Phoenix LiveViewは、JavaScriptを書くことなく、リッチでインタラクティブなWebアプリケーションを可能にします。"
          },
          %{
            "title" => "LiveViewモジュール"
          },
          %{
            "title" => "作成",
            "description" => "カウンターを表示するシンプルなLiveViewを構築してください。"
          }
        ]
      }
    }
  }
]

# Create translations
Enum.each(translations, fn {lesson_slug, translation_data} ->
  case Lessons.create_lesson_translation(lesson_slug, "ja", translation_data) do
    {:ok, _translation} ->
      IO.puts("Created Japanese translation for lesson: #{lesson_slug}")
    {:error, changeset} ->
      IO.puts("Failed to create translation for #{lesson_slug}: #{inspect(changeset.errors)}")
  end
end)

IO.puts("Translation seeding completed!")
