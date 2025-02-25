defmodule Ast do
  defp indent(indent) do
    String.duplicate(" ", indent)
  end

  def pretty_print(ast, indent \\ 1) do
    case ast do
      {:program, function_definitions} ->
        "Program(\n#{indent(indent)}" <>
          "#{Enum.join(Enum.map(function_definitions, fn f -> pretty_print(f, indent + 1) end), "\n")}" <>
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
  end
end
