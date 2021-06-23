"""
    function PVT(;
        n_trials = 20, 
        trial = 1, 
        lb = 2.0, 
        ub = 10.0, 
        width = 600.0, 
        height = 600.0, 
    )

Constructor for creating an instance of the psychomotor vigilance task. 

Arguments:

- `n_trials`: number of trials
- `trial`: current trial
- `lb`: ISI lower bound
- `ub`: ISI upper bound
- `width`: screen width
- `height`: screen height
- `feedback_lock`: locks responding during feedback
- `canvas`: GTK canvas
- `window`: GTK window
- `rts`: reaction times across trials
- `tasks`: scheduled tasks
"""
@concrete mutable struct PVT
    n_trials::Int
    trial 
    lb::Float64
    ub::Float64 
    width::Float64
    height::Float64
    feedback_lock::Bool
    canvas
    window
    start_time
    rts::Vector{Float64}
    tasks::Vector{Timer}
end

function PVT(;
    n_trials = 20, 
    trial = 1, 
    lb = 2.0, 
    ub = 10.0, 
    width = 600.0, 
    height = 600.0, 
    )
    canvas,window = setup_window(width)
    Gtk.showall(window)
    return PVT(
        n_trials, 
        trial, 
        lb, 
        ub, 
        width, 
        height, 
        false,
        canvas, 
        window,
        0.0,
        Float64[],
        Timer[] 
    )
end

function draw_object!(task, object="X")
    c = task.canvas
    w = task.width 
    h = task.height
    x = w / 2
    y = h / 2
    @guarded draw(c) do widget
        ctx = getgc(c)
        select_font_face(ctx, "Arial", Cairo.FONT_SLANT_NORMAL,
             Cairo.FONT_WEIGHT_BOLD);
        set_font_size(ctx, 36)
        set_source_rgb(ctx, 0.0, 0.0, 0.0)
        extents = text_extents(ctx, object)
        x′ = x - (extents[3]/2 + extents[1])
        y′ = y - (extents[4]/2 + extents[2])
        move_to(ctx, x′, y′)
        show_text(ctx, object)
    end
    Gtk.showall(c)
    return nothing
end

function start!()
    task = PVT()
    start!(task)
end

function start!(task::PVT)
    signal_connect((x,y)->press_key!(x, y, task), task.window, "key-press-event")
    run_trial!(task)
end

function run_trial!(task)
    current_trial = task.trial
    isi = sample_isi(task)
    task.start_time = time() + isi
    t1 = Timer(_-> present_stimulus(task), isi)
    t2 = Timer(_-> time_out(task, current_trial), isi + 10)
    push!(task.tasks, t1, t2)
end

function sample_isi(task)
    return rand(Uniform(task.lb, task.ub))
end

function present_stimulus(task)
    task.feedback_lock ? (return nothing) : nothing
    draw_object!(task)
end

function press_key!(gui, event, task::PVT)
    task.feedback_lock ? (return nothing) : nothing
    rt = time() - task.start_time
    teriminate(task)
    push!(task.rts, rt)
    clear!(task)
    task.feedback_lock = true
    draw_object!(task, format(rt))
    if task.trial < task.n_trials
        task.trial += 1
        Timer(_-> clear!(task), 1)
        Timer(_-> task.feedback_lock = false, 1) 
        Timer(_-> run_trial!(task), 1)
    else
        Timer(_-> clear!(task), 1)
        Timer(_-> draw_object!(task, "task complete"), 1.1)
    end
    return nothing
end

function time_out(task, trial)
    task.feedback_lock = true
    clear!(task)
    push!(task.rts, 10.0)
    teriminate(task)
    if task.trial < task.n_trials
        task.trial += 1
        draw_object!(task, "respond faster!")
        Timer(_-> clear!(task), 1) 
        Timer(_-> task.feedback_lock = false, 1) 
        Timer(_-> run_trial!(task), 1)
    else
        Timer(_-> clear!(task), 1)
        Timer(_-> draw_object!(task, "task complete"), 1.1)
    end
end

function teriminate(task)
    close.(task.tasks)
    empty!(task.tasks)
end

format(rt) = string(Int(round(rt * 1000, digits=0)))

function clear!(task)
    c = task.canvas
    w = task.width 
    h = task.height
    @guarded draw(c) do widget
        ctx = getgc(c)
        rectangle(ctx, 0.0, 0.0, w, h)
        set_source_rgb(ctx, .8, .8, .8)
        fill(ctx)
    end
    Gtk.showall(c)
    return nothing
end

setup_window(width::Float64, name="") = setup_window(width, width, name)

"""
    setup_window(width::Float64, height::Float64, name="")

Generate a blank window.
"""
function setup_window(width::Float64, height::Float64, name="")
    canvas = @GtkCanvas()
    window = GtkWindow(canvas, name, width, height)
    Gtk.visible(window, true)
    @guarded draw(canvas) do widget
        ctx = getgc(canvas)
        rectangle(ctx, 0.0, 0.0, width, width)
        set_source_rgb(ctx, .8, .8, .8)
        fill(ctx)
    end
    return canvas,window
end