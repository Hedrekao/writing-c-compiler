defmodule Ast do
  defp indent(indent) do
    String.duplicate(" ", indent)
  end

  def pretty_print(ast, indent \\ 1) do
    case ast do
      {:program, function_definition} ->
        "Program(\n#{indent(indent)}" <>
          "#{pretty_print(function_definition, indent + 1)}" <>
          "\n#{indent(indent - 1)})"

      {:function_definition, name, body} ->
        "Function(\n" <>
          "#{indent(indent)}name=\"#{pretty_print(name, indent + 1)}\",\n" <>
          "#{indent(indent)}body=#{pretty_print(body, indent + 1)}\n" <>
          "#{indent(indent - 1)})"

      {:return, expression} ->
        "Return(\n" <>
          "#{indent(indent)}#{pretty_print(expression, indent + 1)}\n" <>
          "#{indent(indent - 1)})"

      {:unary, operator, expression} ->
        "Unary(\n" <>
          "#{indent(indent)}operator=#{operator},\n" <>
          "#{indent(indent)}expression=\n#{pretty_print(expression, indent + 1)}\n" <>
          "#{indent(indent - 1)})"

      {:constant, value} ->
        "#{indent(indent)}Constant(#{value})"

      {:identifier, value} ->
        "#{value}"
    end
  end

  defmodule Program do
    def new(function_definition), do: {:program, function_definition}
  end

  defmodule FunctionDefinition do
    def new(name, body), do: {:function_definition, name, body}
  end

  defmodule Statement do
    def return(expression), do: {:return, expression}
  end

  defmodule Expression do
    def constant(value), do: {:constant, value}
    def identifier(value), do: {:identifier, value}
    def unary(operator, expresion), do: {:unary, operator, expresion}
  end

  defmodule UnaryOperator do
    def negation, do: :negation
    def bitwise_complement, do: :bitwise_complement
  end

end
