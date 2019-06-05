Configs:

Enable HIGH_RES_TIMERS: General setup → Timers subsystem → High Resolution Timer Support
Set Performance CPU Frequency scaling: CPU Power Management → CPU Frequency scaling → CPU Frequency scaling
Disable KGDB: kernel debugger: KGDB: kernel debugger → Kernel Hacking

Set CONFIG_HZ to 1000Hz (read the notes!): Kernel Features → Timer frequency = 1000 Hz
Disable Allow for memory compaction: Kernel Features → Contiguous Memory Allocator
Disable Contiguous Memory Allocator: Kernel Features → Allow for memory compaction
Enable CONFIG_PREEMPT_RT_FULL: Kernel Features → Preemption Model (Fully Preemptible Kernel (RT)) → Fully Preemptible Kernel (RT)
