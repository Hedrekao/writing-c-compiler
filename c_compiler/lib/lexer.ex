defmodule Lexer do
  @token_patterns [
    {~r/^[a-zA-Z_]\w*\b/, :identifier},
    {~r/^[0-9]+\b/, :constant},
    {~r/^\(/, :open_parenthesis},
    {~r/^\)/, :close_parenthesis},
    {~r/^{/, :open_brace},
    {~r/^}/, :close_brace},
    {~r/^;/, :semicolon},
    {~r/^-/, :negation},
    {~r/^--/, :decrement},
    {~r/^~/, :bitwise_complement}
  ]

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
    @token_patterns
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
