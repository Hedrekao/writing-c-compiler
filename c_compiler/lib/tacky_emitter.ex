defmodule TackyEmitter do
  def emit({:program, function_definition}) do
    function = emit_function(function_definition)
    Tacky.Program.new(function)
  end

  defp emit_function({:function_definition, {_, name}, body}) do
    {instructions, _} = emit_statement(body, 0)
    Tacky.FunctionDefinition.new(name, instructions)
  end

  defp emit_statement({:return, expression}, tmp_var_count) do
    {expr_instructions, expr_var, new_var_count} = emit_expression(expression, tmp_var_count)
    return_instruction = Tacky.Instruction.return(expr_var)
    {expr_instructions ++ [return_instruction], new_var_count}
  end

  defp emit_expression({:constant, value}, tmp_var_count) do
    value_const = Tacky.Value.constant(value)
    {[], value_const, tmp_var_count}
  end

  defp emit_expression({:unary, operator, expr}, tmp_var_count) do
    {expr_instructions, expr_var, new_var_count} = emit_expression(expr, tmp_var_count)

    tacky_operator =
      case operator do
        :negation -> Tacky.UnaryOperator.negation()
        :bitwise_complement -> Tacky.UnaryOperator.bitwise_complement()
      end

    result_var = Tacky.Value.var("tmp.#{new_var_count}")
    unary_instruction = Tacky.Instruction.unary(tacky_operator, expr_var, result_var)

    {expr_instructions ++ [unary_instruction], result_var, new_var_count + 1}
  end
end

