# promptspec-ruby

PromptSpec is a Ruby gem designed to help you call prompts using PromptSpec YAML files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'promptspec'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install promptspec
```

## Usage

To use the gem, you will need to create a YAML file that specifies your prompts. Here's a basic example of what the YAML could include:

```yaml
version: 1
name: "ExamplePrompt"
description: "Generates a prompt for an AI character."

parameters:
  required:
    - "character_name"

prompt:
  model: "gpt-3.5-turbo"
  messages:
    - role: "system"
      content: "You are {character_name}."
```

### Quick Start

Here's how to get started with the PromptSpec gem:

```ruby
require 'promptspec'

# Create an instance of PromptSpec with the path to your YAML file
prompt_spec = PromptSpec.new('path_to_your_prompt_spec.yml')

# Call the gem with the required parameters
response = prompt_spec.call(character_name: 'Sherlock Holmes')

puts response
```

### Configuration

Ensure you have your AI service's API key set in your environment variables. For example, with OpenAI, you would set:

```bash
export OPENAI_API_KEY=your_openai_api_key
```

Alternatively, you can add it to your `.env` file or your application's environment configuration.

## Customization

You can customize the request headers or endpoint URL by setting them in the YAML file or directly manipulating them in your Ruby code.

## Contributing

Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration.
