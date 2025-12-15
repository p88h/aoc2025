// GLPK bindings
package main

foreign import glpk "system:glpk"

@(private = "file")
glp_prob :: struct {}

// GLPK constants
GLP_MIN :: 1
GLP_MAX :: 2
GLP_IV :: 2 // integer variable
GLP_LO :: 2 // lower bound only (x >= lb)
GLP_FX :: 5 // fixed (equality constraint)
GLP_OPT :: 5 // optimal solution
GLP_MSG_OFF :: 0

glp_iocp :: struct {
	msg_lev:   i32,
	br_tech:   i32,
	bt_tech:   i32,
	tol_int:   f64,
	tol_obj:   f64,
	tm_lim:    i32,
	out_frq:   i32,
	out_dly:   i32,
	cb_func:   rawptr,
	cb_info:   rawptr,
	cb_size:   i32,
	pp_tech:   i32,
	mip_gap:   f64,
	mir_cuts:  i32,
	gmi_cuts:  i32,
	cov_cuts:  i32,
	clq_cuts:  i32,
	presolve:  i32,
	binarize:  i32,
	fp_heur:   i32,
	ps_heur:   i32,
	ps_tm_lim: i32,
	sr_heur:   i32,
	use_sol:   i32,
	save_sol:  cstring,
	alien:     i32,
	flip:      i32,
	foo_bar:   [23]f64,
}

foreign glpk {
	glp_create_prob :: proc() -> ^glp_prob ---
	glp_delete_prob :: proc(P: ^glp_prob) ---
	glp_set_obj_dir :: proc(P: ^glp_prob, dir: i32) ---
	glp_add_rows :: proc(P: ^glp_prob, nrs: i32) -> i32 ---
	glp_add_cols :: proc(P: ^glp_prob, ncs: i32) -> i32 ---
	glp_set_row_bnds :: proc(P: ^glp_prob, i: i32, type: i32, lb: f64, ub: f64) ---
	glp_set_col_bnds :: proc(P: ^glp_prob, j: i32, type: i32, lb: f64, ub: f64) ---
	glp_set_obj_coef :: proc(P: ^glp_prob, j: i32, coef: f64) ---
	glp_set_col_kind :: proc(P: ^glp_prob, j: i32, kind: i32) ---
	glp_load_matrix :: proc(P: ^glp_prob, ne: i32, ia: [^]i32, ja: [^]i32, ar: [^]f64) ---
	glp_init_iocp :: proc(parm: ^glp_iocp) ---
	glp_intopt :: proc(P: ^glp_prob, parm: ^glp_iocp) -> i32 ---
	glp_mip_status :: proc(P: ^glp_prob) -> i32 ---
	glp_mip_obj_val :: proc(P: ^glp_prob) -> f64 ---
	glp_mip_col_val :: proc(P: ^glp_prob, j: i32) -> f64 ---
}
