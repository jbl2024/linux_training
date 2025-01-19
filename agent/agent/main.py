import sys
import time
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.markdown import Markdown
from smolagents import ToolCallingAgent, DuckDuckGoSearchTool, HfApiModel

console = Console()


def clean_unicode(text):
    """Convertit les séquences Unicode échappées en caractères normaux"""
    try:
        return str(text).encode("utf-8").decode("utf-8")
    except UnicodeError:
        return text


def run_ai(prompt):
    model_id = "meta-llama/Llama-3.3-70B-Instruct"
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        transient=True,
    ) as progress:
        # Affiche un spinner pendant le traitement
        progress.add_task(description="Réflexion en cours...", total=None)

        try:
            agent = ToolCallingAgent(
                tools=[DuckDuckGoSearchTool()],
                model=HfApiModel(model_id=model_id),
                verbosity_level=0,
            )
            augmented_prompt = f"Tu réponds à cette question qui concerne l'utilisation de linux: {prompt}"
            res = agent.run(augmented_prompt)
            return clean_unicode(res)
        except Exception as e:
            console.print(f"[red]Erreur lors de l'exécution: {str(e)}[/red]")
            return f"Une erreur s'est produite: {str(e)}"


def main(prompt):
    try:
        res = run_ai(prompt)
        console.print(Markdown(res))
    except Exception as e:
        console.print(f"[red]Erreur dans main: {str(e)}[/red]")


def main_cli():
    if len(sys.argv) != 2:
        console.print("[red]Usage: agent 'prompt'[/red]")
        sys.exit(1)
    prompt = sys.argv[1]
    main(prompt)


if __name__ == "__main__":
    main_cli()
