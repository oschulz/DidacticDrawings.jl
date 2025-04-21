

typeof(Base.Multimedia.displays[end])

"""
Standalone: `REPL.REPLDisplay`
IJulia: `IJulia.InlineDisplay`
VS-Code: `VSCodeServer.InlineDisplay` or `VSCodeServer.JuliaNotebookInlineDisplay`
Pluto: `Base.Multimedia.TextDisplay`
"""

parentmodule(typeof(Base.Multimedia.displays[end]))
