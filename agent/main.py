import sys

def main():
    if len(sys.argv) != 2:
        print("Usage: agent 'prompt'")
        sys.exit(1)
    
    prompt = sys.argv[1]
    print(f"Received prompt: {prompt}")

if __name__ == "__main__":
    main()
