from azure.identity import DefaultAzureCredential, get_bearer_token_provider
from openai import AzureOpenAI

class Greeter:
  def __init__(self, endpoint):
    token_provider = get_bearer_token_provider(DefaultAzureCredential(), "https://cognitiveservices.azure.com/.default")
    self.client = AzureOpenAI(
      api_version = "2024-12-01-preview",
      azure_endpoint=endpoint,
      azure_ad_token_provider=token_provider
    )

  def greet(self, name: str) -> str:
    try:
      response = self.client.responses.create(
        model="gpt-4o",
        input=f"Generate a greeting message for {name}."
      )
    except Exception as e:
      print("Error during LLM call: " + str(e))
      return "Hello, " + name + "! (Error generating greeting message.)"
    return response.output_text

    