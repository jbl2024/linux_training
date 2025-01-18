import sys
from smolagents import ToolCallingAgent, DuckDuckGoSearchTool, HfApiModel

model_id = "meta-llama/Llama-3.3-70B-Instruct"

def run_ai(prompt):
    agent = ToolCallingAgent(
        tools=[DuckDuckGoSearchTool()],
        model=HfApiModel(model_id=model_id),
        verbosity_level=0,
    )
    augmented_prompt = f"Tu réponds à cette question qui concerne l'utilisation de linux: {prompt}"
    res = agent.run(augmented_prompt)
    return res


def main(prompt):
    print(f"Votre question: {prompt}")
    res = run_ai(prompt)
    print(res)
    # ... votre code existant ...


def main_cli():
    if len(sys.argv) != 2:
        print("Usage: agent 'prompt'")
        sys.exit(1)
    prompt = sys.argv[1]
    main(prompt)


if __name__ == "__main__":
    main_cli()
