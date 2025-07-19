// Code Editor Hook for Monaco Editor integration
const CodeEditor = {
  mounted() {
    // Load Monaco Editor dynamically
    import('monaco-editor').then(monaco => {
      this.monaco = monaco;
      this.initEditor();
    });
  },

  initEditor() {
    const el = this.el;
    const inputEl = document.getElementById(`${el.id}-input`);
    
    // Get data attributes
    const language = el.dataset.language || 'elixir';
    const theme = el.dataset.theme || 'vs-dark';
    const readonly = el.dataset.readonly === 'true';
    const initialValue = el.dataset.value || '';

    // Register Elixir language if not already registered
    this.registerElixirLanguage();

    // Create editor
    this.editor = this.monaco.editor.create(el, {
      value: initialValue,
      language: language,
      theme: theme,
      readOnly: readonly,
      automaticLayout: true,
      minimap: { enabled: false },
      scrollBeyondLastLine: false,
      lineNumbers: 'on',
      tabSize: 2,
      insertSpaces: true,
      autoIndent: 'full',
      formatOnPaste: true,
      formatOnType: true,
    });

    // Handle changes
    this.editor.onDidChangeModelContent(() => {
      const value = this.editor.getValue();
      inputEl.value = value;
      
      // Dispatch change event to the hidden input
      inputEl.dispatchEvent(new Event('input', { bubbles: true }));
      
      // Push event to the server if phx-change is set
      if (el.dataset.phxChange) {
        this.pushEventTo(el, el.dataset.phxChange, { value });
      }
    });

    // Handle focus and blur events
    this.editor.onDidFocusEditorWidget(() => {
      if (el.dataset.phxFocus) {
        this.pushEventTo(el, el.dataset.phxFocus, {});
      }
    });

    this.editor.onDidBlurEditorWidget(() => {
      if (el.dataset.phxBlur) {
        this.pushEventTo(el, el.dataset.phxBlur, { value: this.editor.getValue() });
      }
    });

    // Handle window resize
    window.addEventListener('resize', () => {
      if (this.editor) {
        this.editor.layout();
      }
    });

    // Handle LiveView updates
    this.handleEvent('update_code_editor', ({ value }) => {
      if (this.editor && value !== this.editor.getValue()) {
        this.editor.setValue(value);
      }
    });
  },

  registerElixirLanguage() {
    // Register Elixir language if not already registered
    if (!this.monaco.languages.getLanguages().some(lang => lang.id === 'elixir')) {
      this.monaco.languages.register({ id: 'elixir' });
      
      // Define Elixir syntax highlighting
      this.monaco.languages.setMonarchTokensProvider('elixir', {
        tokenizer: {
          root: [
            // Module attributes
            [/@[a-zA-Z_]\w*/, 'annotation'],
            
            // Strings
            [/"/, { token: 'string.quote', bracket: '@open', next: '@string' }],
            [/'[^']*'/, 'string'],
            
            // Atoms
            [/:[a-zA-Z_]\w*/, 'constant'],
            
            // Numbers
            [/\d+\.\d+([eE][\-+]?\d+)?/, 'number.float'],
            [/0x[0-9a-fA-F]+/, 'number.hex'],
            [/\d+/, 'number'],
            
            // Keywords
            [/\\\\/, 'operator'],
            [/\b(fn|do|end|after|else|rescue|catch|try|receive|raise|throw|quote|unquote|super|with)\b/, 'keyword'],
            [/\b(if|unless|case|cond|when|for|while|until)\b/, 'keyword.control'],
            [/\b(def|defp|defmodule|defprotocol|defimpl|defmacro|defmacrop|defdelegate|defexception|defstruct|defguard|defguardp)\b/, 'keyword.declaration'],
            [/\b(import|require|use|alias|__MODULE__|__DIR__|__ENV__|__CALLER__|__STACKTRACE__)\b/, 'keyword.namespace'],
            [/\b(true|false|nil)\b/, 'constant.language'],
            
            // Variables
            [/[a-z_]\w*/, 'variable'],
            
            // Module names (capitalized)
            [/[A-Z]\w*/, 'type.identifier'],
            
            // Operators
            [/[=<>!+\-*\/%&\|^~]/, 'operator'],
            [/\.+|~>|<~|<>|<<|>>|=>|<-|::|\|>|&&&|\|\|\||\+\+|\-\-|\*\*|\/\/|<\-\>|<\|>/, 'operator'],
            
            // Punctuation
            [/[\{\}\[\]\(\),;:]/, 'delimiter'],
            
            // Comments
            [/#.*$/, 'comment'],
          ],
          
          string: [
            [/[^"]+/, 'string'],
            [/"/, { token: 'string.quote', bracket: '@close', next: '@pop' }],
            [/\#{/, { token: 'delimiter.bracket', next: '@interpolation' }],
          ],
          
          interpolation: [
            [/\}/, { token: 'delimiter.bracket', next: '@pop' }],
            { include: 'root' }
          ],
        }
      });
      
      // Define Elixir code completion
      this.monaco.languages.registerCompletionItemProvider('elixir', {
        provideCompletionItems: (model, position) => {
          const suggestions = [
            // Keywords
            { label: 'def', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'def ${1:name}(${2:args}) do\n\t${3}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'defp', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'defp ${1:name}(${2:args}) do\n\t${3}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'defmodule', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'defmodule ${1:ModuleName} do\n\t${2}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'if', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'if ${1:condition} do\n\t${2}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'case', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'case ${1:expression} do\n\t${2:pattern} ->\n\t\t${3}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'cond', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'cond do\n\t${1:condition} ->\n\t\t${2}\n\ttrue ->\n\t\t${3}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'for', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'for ${1:item} <- ${2:list} do\n\t${3}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'try', kind: this.monaco.languages.CompletionItemKind.Keyword, insertText: 'try do\n\t${1}\nrescue\n\t${2:error} -> ${3}\nend', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            
            // Common functions
            { label: 'IO.puts', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'IO.puts(${1})', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'IO.inspect', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'IO.inspect(${1}, label: "${2}")', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'Enum.map', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'Enum.map(${1:list}, fn ${2:item} -> ${3} end)', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'Enum.filter', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'Enum.filter(${1:list}, fn ${2:item} -> ${3} end)', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'Enum.reduce', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'Enum.reduce(${1:list}, ${2:acc}, fn ${3:item}, ${4:acc} -> ${5} end)', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'String.split', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'String.split(${1:string}, ${2:pattern})', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'String.trim', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'String.trim(${1:string})', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'List.flatten', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'List.flatten(${1:list})', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'Map.get', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'Map.get(${1:map}, ${2:key})', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
            { label: 'Map.put', kind: this.monaco.languages.CompletionItemKind.Function, insertText: 'Map.put(${1:map}, ${2:key}, ${3:value})', insertTextRules: this.monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
          ];
          
          return {
            suggestions: suggestions
          };
        }
      });
      
      // Define Elixir formatting rules
      this.monaco.languages.registerDocumentFormattingEditProvider('elixir', {
        provideDocumentFormattingEdits: (model) => {
          // Basic formatting for indentation
          // In a real implementation, you might want to use a more sophisticated formatter
          const text = model.getValue();
          const lines = text.split('\n');
          let formattedLines = [];
          let indentLevel = 0;
          
          for (let line of lines) {
            const trimmedLine = line.trim();
            
            // Decrease indent for end, else, rescue, etc.
            if (/^(end|else|rescue|catch|after)\b/.test(trimmedLine)) {
              indentLevel = Math.max(0, indentLevel - 1);
            }
            
            // Add the line with proper indentation
            if (trimmedLine.length > 0) {
              formattedLines.push('  '.repeat(indentLevel) + trimmedLine);
            } else {
              formattedLines.push('');
            }
            
            // Increase indent for lines ending with do or ->
            if (/\b(do|->)$/.test(trimmedLine) || /\b(do|->)\s+#.*$/.test(trimmedLine)) {
              indentLevel++;
            }
          }
          
          return [{
            range: model.getFullModelRange(),
            text: formattedLines.join('\n')
          }];
        }
      });
    }
  },

  updated() {
    // Update editor value if it changed from the server
    const newValue = this.el.dataset.value;
    if (this.editor && newValue !== this.editor.getValue()) {
      this.editor.setValue(newValue);
    }
  },

  destroyed() {
    // Clean up the editor when the element is removed
    if (this.editor) {
      this.editor.dispose();
    }
  }
};

export default CodeEditor;