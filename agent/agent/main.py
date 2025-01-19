import codecs
import re
import sys
import time

from rich.console import Console
from rich.markdown import Markdown
from rich.progress import Progress, SpinnerColumn, TextColumn
from smolagents import DuckDuckGoSearchTool, HfApiModel, ToolCallingAgent

console = Console()


def clean_unicode(text):
    """
    Decodes Unicode escape sequences (e.g., \\u00e9) in a string.
    If the string is already decoded, it returns the string as-is.
    """
    # Check if the string contains any Unicode escape sequences
    if re.search(r"\\u[0-9a-fA-F]{4}", text):
        try:
            # Decode the Unicode escape sequences
            return text.encode("utf-8").decode("unicode_escape")
        except UnicodeDecodeError:
            # If decoding fails, return the original string
            return text
    else:
        # If no escape sequences are found, return the string as-is
        return text


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
            Tu réponds à cette question toujours en français.
            Voici le format de réponse que tu dois toujours respecter :
                ## réponse directe ##
                Ici la réponse directe

                ## Explications détaillées ##
                Ici des explications qui permettent d'en savoir plus et d'aller plus loins

                ## Informations sur la sécurité ##
                Ici des informations sur la sécurité et les précautions à prendre si la commande est dangereuse
                        
            Question: 
            {prompt}

            Réponds à la question en respectant le format demandé (reponse directe, explications, securité)
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
    prompt = sys.argv[1].encode("utf-8").decode("utf-8")
    main(prompt)


if __name__ == "__main__":
    # Définir l'encodage par défaut
    sys.stdout.reconfigure(encoding="utf-8")
    main_cli()
