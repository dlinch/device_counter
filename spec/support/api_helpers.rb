module ApiHelpers
  def parsed_body
    @parsed ||= JSON.load(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, parse_json: true
end