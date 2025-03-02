defmodule Tacky do
  defp indent(indent) do
    String.duplicate(" ", indent)
  end

  def pretty_print(tacky, indent \\ 1) do
    case tacky do
      {:program, function_definition} ->
        "Program(\n#{indent(indent)}" <>
          "#{pretty_print(function_definition, indent + 1)}" <>
          "\n#{indent(indent - 1)})"

      {:function_definition, name, instructions} ->
        "Function(\n" <>
          "#{indent(indent)}name=#{pretty_print(name, indent + 1)},\n" <>
          "#{indent(indent)}body=\n#{indent(indent)}  #{Enum.join(Enum.map(instructions, fn instruction -> pretty_print(instruction, indent + 1) end), ",\n#{indent(indent)}  ")}\n" <>
          "#{indent(indent - 1)})"

      {:return, val} ->
        "Return(value=#{pretty_print(val, indent)})"

      {:unary, operator, src, dest} ->
        "Unary(operator=#{operator}, src=#{pretty_print(src, indent)}, dest=#{pretty_print(dest, indent)})"

      {:constant, value} ->
        "Constant(#{value})"

      {:var, value} ->
        "Var(#{value})"
    end
  end

  defmodule Program do
    def new(function_definition), do: {:program, function_definition}
  end

  defmodule FunctionDefinition do
    def new(name, body), do: {:function_definition, name, body}
  end

  defmodule Instruction do
    def return(value), do: {:return, value}
    def unary(operator, src, dest), do: {:unary, operator, src, dest}
  end

  defmodule UnaryOperator do
    def negation, do: :negation
    def bitwise_complement, do: :bitwise_complement
  end

  defmodule Value do
    def constant(value), do: {:constant, value}
    def var(value), do: {:var, value}
  end
end
