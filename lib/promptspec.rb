# lib/prompt_spec.rb
require 'yaml'
require 'erb'
require 'json'
require 'net/http'
require 'uri'

class PromptSpec
  class Error < StandardError; end
  class FileNotFoundError < Error; end
  class ParseError < Error; end
  class RequiredParameterError < Error; end
  class EndpointError < Error; end

  attr_reader :file_path, :validate_required_params

  def initialize(file_path, validate_required_params: true)
    @file_path = file_path
    @validate_required_params = validate_required_params
    load_parse_file!
  end

  def call(**parameters)
    validate_required_inputs!(parameters) if validate_required_params
    parse_prompt_messages(parameters)
    construct_endpoint_request
  end

  private

  def load_parse_file!
    path = defined?(Rails) ? Rails.root.join('app', 'prompts', file_path) : File.expand_path(file_path)
    raise FileNotFoundError, "File not found: #{path}" unless File.exist?(path)
    @yaml_content = YAML.safe_load(File.read(path))
  rescue Psych::SyntaxError => e
    raise ParseError, "YAML parsing error: #{e.message}"
  end

  def validate_required_inputs!(parameters)
    required_params = @yaml_content.dig('parameters', 'required') || []
    missing_params = required_params - parameters.keys.map(&:to_s)
    raise RequiredParameterError, "Missing required parameters: #{missing_params.join(', ')}" unless missing_params.empty?
  end

  def parse_prompt_messages(parameters)
    messages = @yaml_content['prompt']['messages'].map do |message|
      content = message['content']
      parameters.each do |key, value|
        content.gsub!("{#{key}}", value.to_s)
      end
      { role: message['role'], content: content }
    end
    @yaml_content['prompt']['messages'] = messages
  end

  def construct_endpoint_request
    endpoint = @yaml_content['endpoint'] || construct_default_endpoint
    headers = construct_headers
    payload = @yaml_content['prompt']
  
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
  
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = payload.to_json
  
    response = http.request(request)
  
    response.body
  rescue => e
    { error: e.message }
  end

  def construct_default_endpoint
    @model = @yaml_content['prompt']['model']
    case @model
    when 'gpt-4'
      'https://api.openai.com/v1/chat/completions'
    when 'gpt-3.5-turbo'
      'https://api.openai.com/v1/chat/completions'
    else
      raise EndpointError, "Unknown model: #{model}"
    end
  end

  def construct_headers
    # Placeholder logic for constructing headers
    headers = @yaml_content['headers'] || {}
    if @model == 'gpt-4' && headers.empty?
      api_key = ENV['OPENAI_API_KEY']
      raise EndpointError, "Missing OpenAI API Key" unless api_key
      headers['Authorization'] = "Bearer #{api_key}"
    end
    headers['Content-Type'] = 'application/json'
    headers
  end
end