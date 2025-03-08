# repos.py
"""
A placeholder logic for how you define the repos you want to fetch.
You might store them in a 'repos' table or config. For demonstration, let's do a minimal approach.
"""

def get_repo_list():
    """
    Return a hard-coded list or read from DB.
    For example: [("owner1","repo1"), ("owner2","repo2")]
    """
    return [
         ("ni","labview-icon-editor"),
         ("ni","actor-framework"),
         ("dotnet","core"),
         ("facebook","react"),
         ("tensorflow","tensorflow"),
         ("epics","reconos"),
         ("openfoam","openfoam-dev"),
         ("freecad","freecad"),
         ("fritzing","fritzing-app"),
         ("qucs","qucs"),
         ("openscad","openscad"),
         ("node-red","nodered"),
         ("openplc","openplc-ide"),
         ("eclipse","mraa"),
    ]