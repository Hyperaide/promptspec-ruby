# lib/prompt_spec.rb
require 'yaml'
require 'erb'
require 'json'
require 'net/http'
require 'uri'

class PromptSpec
  attr_reader :file_path, :validate_required_params, :parameters, :yaml_content

  def initialize(file_path, validate_required_params: true)
    @file_path = file_path
    @validate_required_params = validate_required_params
    load_parse_file!
  end

  def call(**parameters)
    @parameters = parameters
    validate_required_inputs! if @validate_required_params
    parse_prompt_messages
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

  def validate_required_inputs!
    required_params = @yaml_content.dig('parameters', 'required') || []
    missing_params = required_params - @parameters.keys.map(&:to_s)
    raise RequiredParameterError, "Missing required parameters: #{missing_params.join(', ')}" unless missing_params.empty?
  end

  def parse_prompt_messages
    @yaml_content['prompt']['messages'].each do |message|
      content = message['content']
      @parameters.each do |key, value|
        content.gsub!("{#{key}}", value.to_s) if content.include?("{#{key}}")
      end
      message['content'] = content
    end
  end

  def construct_endpoint_request
    endpoint = @yaml_content['url'] || construct_default_endpoint
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
    @model ||= @yaml_content['prompt']['model']
    case @model
    when 'gpt-4', 'gpt-4-0613', 'gpt-4-32k', 'gpt-4-32k-0613', 'gpt-3.5-turbo', 'gpt-3.5-turbo-16k', 'gpt-3.5-turbo-0613', 'gpt-3.5-turbo-16k-0613'
      'https://api.openai.com/v1/chat/completions'
    else
      raise EndpointError, "Unknown model: #{model}"
    end
  end

  def construct_headers
    @headers ||= begin
      yaml_headers = @yaml_content.fetch('headers', {})
      headers = {}
  
      case @model
      when 'gpt-4', 'gpt-4-0613', 'gpt-4-32k', 'gpt-4-32k-0613', 'gpt-3.5-turbo', 'gpt-3.5-turbo-16k', 'gpt-3.5-turbo-0613', 'gpt-3.5-turbo-16k-0613'
        api_key = ENV['OPENAI_API_KEY']
        headers['Authorization'] = "Bearer #{api_key}" if api_key
      # Add more cases here for other providers
      end
      else
        headers.merge!(yaml_headers)
      end
  
      headers['Content-Type'] = 'application/json' unless headers.key?('Content-Type')
      headers
    end
  end
end