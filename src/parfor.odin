package main

import "core:fmt"
import "core:sync"
import "core:thread"
import "core:time"

Instance :: struct {
	userdata:     rawptr,
	callback:     proc(),
	id, count:    int,
	thread_count: int,
	sema:         sync.Sema,
	wait_group:   sync.Wait_Group,
	finished:     bool,
	lockfree:     bool,
}

// 'for_*' procs and thread_proc access this through context.user_ptr
create_instance :: proc(thread_count: int) -> Instance {
	return {thread_count = thread_count}
}

@(private)
_for :: proc(self: ^Instance, count: int, data: rawptr, callback: proc(), lockfree: bool) {
	self.userdata = data
	self.callback = callback
	self.count = count
	self.id = 0
	self.lockfree = lockfree
	self.wait_group.counter = self.thread_count
	sync.post(&self.sema, self.thread_count)
	do_work(self)
}

// uses hot looping, better for small work (count agnostic)
// ^Instance should be set to context.user_ptr
for_lockfree :: proc(count: int, data: rawptr, work: proc()) {
	self := (^Instance)(context.user_ptr)
	_for(self, count, data, work, true)
	for sync.atomic_load_explicit(&self.wait_group.counter, .Relaxed) != 0 {
		// waiting
	}
}

// uses cond variable, better for large work (count agnostic)
// ^Instance should be set to context.user_ptr
for_locking :: proc(count: int, data: rawptr, work: proc()) {
	self := (^Instance)(context.user_ptr)
	_for(self, count, data, work, false)
	sync.wait(&self.wait_group)
}

// call before destroying threads
finish :: proc(self: ^Instance) {
	self.finished = true
	sync.post(&self.sema, self.thread_count)
}

@(private)
do_work :: proc(self: ^Instance) {
	for {
		id := sync.atomic_add_explicit(&self.id, 1, .Relaxed)
		(id < self.count) or_break
		context.user_index = id
		context.user_ptr = self.userdata
		self.callback()
	}
}

// use inside of work proc to get work id and data
pull :: proc($T: typeid) -> (int, ^T) {
	ptr := (^T)(context.user_ptr)
	return context.user_index, ptr
}

// create and start thread with this proc
// ^Instance should be set to context.user_ptr
thread_proc :: proc() {
	self := (^Instance)(context.user_ptr)
	for {
		sync.wait(&self.sema)
		if self.finished do return
		do_work(self)
		work_done(self)
	}
}

@(private)
work_done :: proc(self: ^Instance) {
	wg := &self.wait_group
	if self.lockfree {
		sync.atomic_sub_explicit(&wg.counter, 1, .Release)
	} else {
		sync.wait_group_done(wg)
	}
}

THREAD_COUNT :: 4
parfor_init :: proc() {
	
	instance := create_instance(THREAD_COUNT)
	context.user_ptr = &instance

	threads: [THREAD_COUNT]^thread.Thread
	for _, i in threads {
		context.user_index = i + 1
		threads[i] = thread.create_and_start(thread_proc, context)
	}

}

@(private)
example :: proc() {
	SIZE :: THREAD_COUNT * 4
	data: [SIZE]int
	for_lockfree(SIZE, &data, proc() {
		id, data := pull([SIZE]int)
		data[id] = id + 1
		time.sleep(10 * time.Microsecond)
	})
	fmt.println(data)

	data[SIZE - 1] *= 2

	for_locking(SIZE, &data, proc() {
		id, data := pull([SIZE]int)
		data[id] -= 2 * (id + 1)
		time.sleep(10 * time.Millisecond)
	})
	fmt.println(data)

	// finish(&instance)
	// for t in threads {
	// 	thread.destroy(t)
	// }
}
