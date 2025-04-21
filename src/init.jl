# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

const _init_lock = ReentrantLock()


_display_type::Symbol = :unknown

function _get_display_type()
    global _display_type
    @lock _init_lock begin
        if _display_type == :unknown
            LDT = typeof(Base.Multimedia.displays[end])

            # Standalone: `REPL.REPLDisplay`
            # IJulia notebook: `IJulia.InlineDisplay`
            # VS-Code: `VSCodeServer.InlineDisplay`
            # VS-Code notebook: `VSCodeServer.JuliaNotebookInlineDisplay`
            # Pluto notebook: `Base.Multimedia.TextDisplay`
            # Makie: `REPL.REPLDisplay`
            # Plots in desktop mode: `Plots.PlotsDisplay`

            if nameof(parentmodule(LDT)) in [:REPL, :Plots]
                _display_type = :desktop
            else
                _display_type = :html
            end
        end
        return _display_type
    end
end


_makie_initialized::Bool = false

function _init_makie()
    global _makie_initialized
    @lock _init_lock begin
        if !_makie_initialized
            if Makie.current_backend() isa Missing
                display_type = _get_display_type()

                #=

                # Loading Makie like this doesn't seem to be quite right, results in
                # `ERROR: MethodError: no method matching WGLMakie.ScreenConfig(::Float64, ::Nothing, ::MakieCore.Automatic, ::MakieCore.Automatic, ::Nothing)`
                # on `display(fig)`:

                if display_type == :desktop
                    @info "Looks like we're on a desktop (standalone Julia) display, importing WGLMakie"
                    @eval Main begin
                        import GLMakie
                        # GLMakie.activate!()
                    end
                    sleep(2)
                elseif display_type == :html
                    @info "Looks like we're on an HTML-compatible (e.g. notebook or VS-Code) display, importing WGLMakie"
                    @eval Main begin
                        import WGLMakie
                        # WGLMakie.activate!()
                    end
                    sleep(2)
                else
                    throw(ErrorException("Unknown display type: $display_type"))
                end
                =#

                # User needs to load Makie backend manually for now:

                if display_type == :desktop
                    error("No Makie backend loaded, run `import GLMakie`")
                elseif display_type == :html
                    error("No Makie backend loaded, run `import WGLMakie`")
                else
                    throw(ErrorException("Unknown display type: $display_type"))
                end
            else
                _makie_initialized = true
            end
            _makie_initialized = true
        end
    end
    return nothing
end



"""
    DidacticDrawings.init2d()

Initialize the 2D drawing environment.
"""
function init2d()
    _init_makie()

    fig = Figure()
    ax = Axis(fig[1, 1])

    display(fig)
    return nothing
end


"""
    DidacticDrawings.init3d()

Initialize the 3D drawing environment.
"""
function init3d()
    _init_makie()

    fig = Figure()
    ax = LScene(fig[1, 1])
    cam = Camera3D(ax.scene, projectiontype = Makie.Perspective)
    cam.eyeposition[] = [5.738881445453077, -4.002837494485787, 4.49961730493607]
    cam.lookat[] = [1.510599942850802, 5.435164132214021, 0.36318992604854294]

    display(fig)
    return nothing
end
