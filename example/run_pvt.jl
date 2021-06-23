cd(@__DIR__)
using Pkg
Pkg.activate("..")
using PsychomotorVigilanceTask, Revise
task = PVT(;n_trials=10)
start!(task)
