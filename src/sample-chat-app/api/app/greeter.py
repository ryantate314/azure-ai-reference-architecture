from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient

class Greeter:
  def __init__(self, endpoint):
    self.project = AIProjectClient(
      endpoint=endpoint,  # Replace with your endpoint
      credential=DefaultAzureCredential()
    )
    self.client = self.project.get_openai_client(api_version="2024-12-01-preview")
    print("Base Url: " + str(self.client.base_url))

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

    