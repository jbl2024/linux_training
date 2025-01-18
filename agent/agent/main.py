import sys
from smolagents import CodeAgent, DuckDuckGoSearchTool, HfApiModel

def run_ai(prompt):
    agent = CodeAgent(tools=[DuckDuckGoSearchTool()], model=HfApiModel())
    res = agent.run("How many seconds would it take for a leopard at full speed to run through Pont des Arts?")
    return res



def main(prompt):
    print(f"Agent received prompt: {prompt}")
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
