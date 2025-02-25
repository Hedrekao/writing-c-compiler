defmodule Lexer do
  @identifier_regex ~r/^[a-zA-Z_]\w*\b/
  @constant_regex ~r/^[0-9]+\b/
  @open_parenthesis_regex ~r/^\(/
  @close_parenthesis_regex ~r/^\)/
  @open_brace_regex ~r/^{/
  @close_brace_regex ~r/^}/
  @semicolon_regex ~r/^;/

  defp lex_rec(input, tokens) when input != "" do
    # Skip whitespace
    if String.starts_with?(input, " ") do
      input = String.trim_leading(input, " ")
      lex_rec(input, tokens)
    else
      # Get all matches and find the longest one
      matches = get_all_matches(input)

      if matches == [] do
        # TODO: handle error properly
        {c, _} = String.split_at(input, 1)
        {:error, "unexpected character '#{c}'"}
      else
        # Find the longest match
        {match_text, token_type} =
          Enum.max_by(matches, fn {[match | _], _} -> String.length(match) end)

        # Extract matched text
        [matched | _] = match_text
        match_length = String.length(matched)

        new_token = case token_type do
          :identifier ->
            case matched do
              "int" -> {:int, matched}
              "return" -> {:return, matched}
              "void" -> {:void, matched}
              _ -> {:identifier, matched}
            end
          _ -> {token_type, matched}
        end

        # Continue lexing with the rest of the input
        remaining = String.slice(input, match_length..-1//1)
        lex_rec(remaining, tokens ++ [new_token])
      end
    end
  end

  defp lex_rec("", tokens) do
    {:ok, tokens}
  end

  defp get_all_matches(input) do
    [
      {@identifier_regex, :identifier},
      {@constant_regex, :constant},
      {@open_parenthesis_regex, :open_parenthesis},
      {@close_parenthesis_regex, :close_parenthesis},
      {@open_brace_regex, :open_brace},
      {@close_brace_regex, :close_brace},
      {@semicolon_regex, :semicolon}
    ]
    |> Enum.map(fn {regex, token} -> {Regex.run(regex, input), token} end)
    |> Enum.filter(fn {match, _} -> match != [] and match != nil end)
  end

  def lex(file_path) do
    input =
      File.stream!(file_path)
      |> Enum.map(&String.trim/1)
      |> Enum.join(" ")

    lex_rec(input, [])
  end
end
