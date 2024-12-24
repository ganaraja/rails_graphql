module GraphQLHelpers
  def camelize_keys(params)
    params.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
  end

  def sanitize_arg(arg)
    arg.nil? ? 'null' : (arg.is_a?(String) ? "\"#{arg}\"" : arg)
  end
end