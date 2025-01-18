import sys
import time
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.panel import Panel
from rich.markdown import Markdown
from smolagents import ToolCallingAgent, DuckDuckGoSearchTool, HfApiModel

console = Console()

def clean_unicode(text):
    """Convertit les séquences Unicode échappées en caractères normaux"""
    return bytes(text, 'ascii').decode('unicode-escape')

def run_ai(prompt):
    model_id = "meta-llama/Llama-3.3-70B-Instruct"
    
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        transient=True,
    ) as progress:
        # Affiche un spinner pendant le traitement
        progress.add_task(description="Réflexion en cours...", total=None)
        
        agent = ToolCallingAgent(
            tools=[DuckDuckGoSearchTool()],
            model=HfApiModel(model_id=model_id),
            verbosity_level=0,
        )
        
        augmented_prompt = f"Tu réponds à cette question qui concerne l'utilisation de linux: {prompt}"
        res = agent.run(augmented_prompt)
        return clean_unicode(res)

def format_output(question, answer):
    # Crée un panel pour la question
    question_panel = Panel(
        f"[bold blue]Question:[/bold blue]\n{question}",
        title="Votre demande",
        border_style="blue"
    )
    
    # Crée un panel pour la réponse avec support Markdown
    answer_md = Markdown(answer)
    answer_panel = Panel(
        answer_md,
        title="Réponse",
        border_style="green"
    )
    
    return question_panel, answer_panel

def main(prompt):
    # Affiche la question et obtient la réponse
    res = run_ai(prompt)
    
    # Formate et affiche le résultat
    question_panel, answer_panel = format_output(prompt, res)
    console.print(question_panel)
    console.print("\n")
    console.print(answer_panel)

def main_cli():
    if len(sys.argv) != 2:
        console.print("[red]Usage: agent 'prompt'[/red]")
        sys.exit(1)
    
    prompt = sys.argv[1]
    main(prompt)

if __name__ == "__main__":
    main_cli()