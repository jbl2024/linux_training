import sys
import time
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.markdown import Markdown
from smolagents import ToolCallingAgent, DuckDuckGoSearchTool, HfApiModel

console = Console()

def clean_unicode(text):
    """Convertit les séquences Unicode échappées en caractères lisibles en français"""
    try:
        # Si le texte contient des séquences échappées
        if '\\u' in str(text) or '\\n' in str(text):
            # Première passe : traiter les séquences \u
            text = text.encode('utf-8').decode('unicode-escape')
            # Deuxième passe : normaliser les retours à la ligne
            text = text.replace('\\n', '\n')
            # Troisième passe : s'assurer que c'est en UTF-8 propre
            return text.encode('utf-8').decode('utf-8')
        return str(text)
    except UnicodeError:
        # En cas d'erreur, retourner le texte tel quel
        return str(text)

def run_ai(prompt):
    model_id = "meta-llama/Llama-3.3-70B-Instruct"
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        transient=True,
    ) as progress:
        progress.add_task(description="Réflexion en cours...", total=None)
        
        try:
            agent = ToolCallingAgent(
                tools=[DuckDuckGoSearchTool()],
                model=HfApiModel(model_id=model_id),
                verbosity_level=0,
            )
            # Spécifier l'encodage UTF-8 dans le prompt
            augmented_prompt = f"""
            # encoding: utf-8
            Tu réponds à cette question qui concerne l'utilisation de linux, en utilisant des caractères UTF-8 avec accents : {prompt}
            """
            res = agent.run(augmented_prompt)
            return clean_unicode(res)
        except Exception as e:
            console.print(f"[red]Erreur lors de l'exécution: {str(e)}[/red]")
            return f"Une erreur s'est produite: {str(e)}"

def main(prompt):
    try:
        res = run_ai(prompt)
        # Utiliser rich pour l'affichage avec support UTF-8
        console.print(Markdown(res))
    except Exception as e:
        console.print(f"[red]Erreur dans main: {str(e)}[/red]")

def main_cli():
    if len(sys.argv) != 2:
        console.print("[red]Usage: agent 'prompt'[/red]")
        sys.exit(1)
    # S'assurer que l'entrée est en UTF-8
    prompt = sys.argv[1].encode('utf-8').decode('utf-8')
    main(prompt)

if __name__ == "__main__":
    # Définir l'encodage par défaut
    sys.stdout.reconfigure(encoding='utf-8')
    main_cli()
    