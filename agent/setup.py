from setuptools import setup, find_packages

setup(
    name="agent-cli",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[],
    entry_points={
        'console_scripts': [
            'agent=agent.main:main_cli',
        ],
    },
)
