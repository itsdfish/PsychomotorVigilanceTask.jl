# PsychomotorVigilenceTask

This package impliments the psychomotor vigilance task (PVT) in the Julia programming language. The PVT measures decrements in sustained attention as the result of fatigue and sleep deprivation. On each trial, a stimulus appears after a delay uniformly distributed between 2 and 10 seconds. The goal is to respond as quickly as possible without responding before the stimulus onset. After a response is made via the spacebar, the reaction time of the current trial is displayed in milliseconds for 1 second. An average reaction time of 250 to 300 milliseconds is typical for well-rested individuals. 

# Example

The PVT can be used as follows: 

```julia
using PsychomotorVigilenceTask
task = PVT()
start!(task)
```
The default settings can be overwritten by passing values to the desired keyword arguments in `PVT()`. Reaction times can be accessed with `task.rts`

# References

Dinges, D. F., & Powell, J. W. (1985). Microcomputer analyses of performance on a portable, simple visual RT task during sustained operations. Behavior research methods, instruments, & computers, 17(6), 652-655.