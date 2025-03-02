defmodule CCompiler do
  def start(_type, _args) do
    case parse_args() do
      {:ok, file_path, mode} ->
        compile(file_path, mode)

      {:error, message} ->
        IO.puts(:stderr, "Error: #{message}")
        System.halt(1)
    end

    {:ok, self()}
  end

  defp parse_args do
    args = System.argv()

    case args do
      [file_path | rest] ->
        mode = List.first(rest) || "ast"
        {:ok, file_path, mode}

      [] ->
        {:error, "No input file specified"}
    end
  end

  defp compile(file_path, mode) do
    case mode do
      "--lex" ->
        # Only run the lexer
        with {:ok, tokens} <- lex_file(file_path) do
          IO.inspect(tokens, label: "Tokens")
        end

      "--parse" ->
        # Run lexer and parser
        with {:ok, tokens} <- lex_file(file_path),
             {:ok, ast} <- parse_tokens(tokens) do
          IO.puts(Ast.pretty_print(ast))
        end

      "--tacky" ->
        # Run lexer, parser, and tacky code generator
        with {:ok, tokens} <- lex_file(file_path),
             {:ok, ast} <- parse_tokens(tokens),
             {:ok, tacky} <- emit_tacky(ast) do
          IO.puts(Tacky.pretty_print(tacky))
        end

      "--codegen" ->
        # Run the full pipeline
        with {:ok, tokens} <- lex_file(file_path),
             {:ok, ast} <- parse_tokens(tokens),
             {:ok, assembly} <- generate_assembly(ast) do
          IO.inspect(tokens, label: "Tokens")
          IO.puts(Ast.pretty_print(ast))
          IO.inspect(assembly, label: "Assembly")
        end

      _ ->
        with {:ok, tokens} <- lex_file(file_path),
             {:ok, ast} <- parse_tokens(tokens),
             {:ok, assembly} <- generate_assembly(ast),
             {:ok} <- emit_assembly(assembly, file_path) do
          :ok
        end
    end
  end

  defp lex_file(file_path) do
    case Lexer.lex(file_path) do
      {:ok, tokens} ->
        {:ok, tokens}

      {:error, message} ->
        IO.puts(:stderr, "Lexer error: #{message}")
        System.halt(1)
    end
  end

  defp parse_tokens(tokens) do
    case Parser.parse_program(tokens) do
      {:ok, ast} ->
        {:ok, ast}

      {:error, message} ->
        IO.puts(:stderr, "Parser error: #{message}")
        System.halt(1)
    end
  end

  defp emit_tacky(ast) do
    {:ok, TackyEmitter.emit_tacky(ast)}
  end

  defp generate_assembly(ast) do
    {:ok, Assembler.parse_program(ast)}
  end

  defp emit_assembly(assembly, input_file) do
    CodeEmitter.emit(assembly, input_file)
  end

end
