defmodule Parser do
  defp expect_token([], expected_type), do: raise("Expected token :#{expected_type}, got EOF")

  defp expect_token([{token_type, value} | rest], expected_type) do
    if token_type == expected_type do
      rest
    else
      raise "Expected token :#{expected_type}, got token :#{token_type} \"#{value}\""
    end
  end

  defp peek_token([], _), do: false

  defp peek_token([{token_type, _} | _], expected_type) do
    token_type == expected_type
  end

  def parse_program(tokens) do
    try do
      {function, remaining_tokens} = parse_function_definition(tokens)

      if remaining_tokens == [] do
        {:ok, Ast.Program.new(function)}
      else
        {:error, "Expected EOF, got #{inspect(remaining_tokens)}"}
      end
    rescue
      e in RuntimeError -> {:error, Exception.message(e)}
    end
  end

  defp parse_function_definition(tokens) do
    tokens = expect_token(tokens, :int)
    peek_token(tokens, :identifier) || raise "Expected function name, got #{inspect(hd(tokens))}"
    {function_name, tokens} = parse_expression(tokens)
    tokens = expect_token(tokens, :open_parenthesis)
    tokens = expect_token(tokens, :void)
    tokens = expect_token(tokens, :close_parenthesis)
    tokens = expect_token(tokens, :open_brace)

    {function_body, tokens} = parse_statement(tokens)

    tokens = expect_token(tokens, :close_brace)

    {Ast.FunctionDefinition.new(function_name, function_body), tokens}
  end

  defp parse_statement(tokens) do
    tokens = expect_token(tokens, :return)
    {return_expression, tokens} = parse_expression(tokens)
    tokens = expect_token(tokens, :semicolon)

    {Ast.Statement.return(return_expression), tokens}
  end

  defp parse_expression([]), do: raise("Expected expression, got EOF")

  defp parse_expression([{:identifier, value} | rest]) do
    {Ast.Expression.identifier(value), rest}
  end

  defp parse_expression([{:constant, value} | rest]) do
    {Ast.Expression.constant(String.to_integer(value)), rest}
  end

  defp parse_expression([{unary_operand, _} | rest])
       when unary_operand == :negation or unary_operand == :bitwise_complement do
    {expression, rest} = parse_expression(rest)
    {Ast.Expression.unary(unary_operand, expression), rest}
  end

  defp parse_expression([{:open_parenthesis, _} | rest]) do
    {expression, rest} = parse_expression(rest)
    {expression, expect_token(rest, :close_parenthesis)}
  end
end
