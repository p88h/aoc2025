package main

import "core:fmt"
import "core:sync"
import "core:thread"

@(private = "file")
thread_pool_initialized := false
@(private = "file")
global_thread_pool: thread.Pool
@(private = "file")
NUM_THREADS :: 6

init_threads :: proc(use_threads: bool) {
    if !use_threads {
        return
    }
	thread.pool_init(&global_thread_pool, context.allocator, NUM_THREADS)
	thread.pool_start(&global_thread_pool)
    thread_pool_initialized = true
}

stop_threads :: proc() {
	thread.pool_finish(&global_thread_pool)
	thread.pool_destroy(&global_thread_pool)
}

@(private = "file")
ShardFn :: struct {
	data:  rawptr,
	fn:    proc(data: rawptr, shard: int),
	group: sync.Wait_Group,
}

run_shards :: proc($num_shards: int, data: $E, shard_fn: proc(data: E, shard: int)) {
	task_proc :: proc(t: thread.Task) {
		sfn := cast(^ShardFn)t.data
		shard_fn := cast(proc(_: E, _: int))sfn.fn
		data := cast(E)sfn.data
		shard := t.user_index
		shard_fn(data, shard)
		sync.wait_group_done(&sfn.group)
	}
	sfn := ShardFn {
		data  = cast(rawptr)data,
		fn    = cast(proc(_: rawptr, _: int))shard_fn,
		group = sync.Wait_Group{},
	}
	for shard in 0 ..< num_shards {
		if thread_pool_initialized {
			sync.wait_group_add(&sfn.group, 1)
			thread.pool_add_task(&global_thread_pool, context.allocator, task_proc, &sfn, shard)
		} else {            
			// Fallback to single-threaded execution if thread pool is not initialized
			shard_fn(data, shard)
		}
	}
	if thread_pool_initialized {
		sync.wait_group_wait(&sfn.group)
	}
}
