using SafeTestsets

@safetestset "PsychomotorVigilanceTask.jl" begin
    using PsychomotorVigilanceTask, Test
    import PsychomotorVigilanceTask: press_key!, present_stimulus

    # run once for precompilation
    task = PVT(;n_trials=1)
    task.start_time = 1 + time()
    sleep(1)
    present_stimulus(task)
    sleep(.5)
    press_key!(task.window, nothing, task)

    task = PVT(;n_trials=1)
    task.start_time = 1 + time()
    sleep(1)
    present_stimulus(task)
    sleep(.5)
    press_key!(task.window, nothing, task)
    @test task.rts[1] ≈ .5 atol = 1e-2
end
