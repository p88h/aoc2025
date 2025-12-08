package main

import "core:thread"

@(private = "file")
global_thread_pool : thread.Pool
NUM_THREADS :: 6

init_threads :: proc() {
    thread.pool_init(&global_thread_pool, context.allocator, NUM_THREADS)
    thread.pool_start(&global_thread_pool)
}

stop_threads :: proc() {
    thread.pool_finish(&global_thread_pool)
    thread.pool_destroy(&global_thread_pool)
}

