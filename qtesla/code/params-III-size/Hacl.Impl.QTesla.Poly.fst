module Hacl.Impl.QTesla.Poly

open FStar.HyperStack
open FStar.HyperStack.ST
open FStar.Mul

module I = FStar.Int
module I8 = FStar.Int8
module I16 = FStar.Int16
module I32 = FStar.Int32
module I64 = FStar.Int64
module UI16 = FStar.UInt16
module UI32 = FStar.UInt32
module UI64 = FStar.UInt64
open FStar.Int.Cast

open LowStar.Buffer

open Lib.IntTypes
open Lib.Buffer
open Lib.ByteBuffer

open C.Loops

open Hacl.Impl.QTesla.Params
open Hacl.Impl.QTesla.Constants
open Hacl.Impl.QTesla.Globals

#reset-options "--z3rlimit 100 --max_fuel 0 --max_ifuel 0 --admit_smt_queries true"

val ntt:
    a: poly
  -> w: poly
  -> Stack unit
    (requires fun h -> live h a /\ live h w /\ disjoint a w)
    (ensures fun h0 _ h1 -> modifies1 a h0 h1)

let ntt a w =
    push_frame();
    let numoProblems = create (size 1) (params_n >>. (size 1)) in
    let jTwiddle = create (size 1) (size 0) in

    while // Outermost for loop
        #(fun h -> live h numoProblems /\ live h jTwiddle /\ live h a /\ live h w)
        #(fun _ h -> live h numoProblems /\ live h jTwiddle /\ live h a /\ live h w)
        (fun _ -> numoProblems.(size 0) >. (size 0))
        (fun _ ->
            push_frame();
            let jBuf = create (size 1) (size 0) in
            let jFirst = create (size 1) (size 0) in            
            let cond () : Stack bool
              (requires fun h -> live h jFirst)
              (ensures fun h0 _ h1 -> live h1 jFirst)
            = jFirst.(size 0) <. params_n in
            while // Middle for loop
                #(fun h -> live h numoProblems /\ live h jTwiddle /\ live h jBuf /\ live h jFirst /\ live h a /\ live h w)
                #(fun _ h -> live h numoProblems /\ live h jTwiddle /\ live h jBuf /\ live h jFirst /\ live h a /\ live h w)
                cond
                (fun _ ->
                    let jTwiddleVal = jTwiddle.(size 0) in
                    let wj:elem = w.(jTwiddleVal) in
                    jTwiddle.(size 0) <- jTwiddleVal +. (size 1);
                    // Innermost for loop. Have to use a while because the middle for loop's increment depends on the
                    // final value of j from each inner for loop, so its scope can't be constrained to the for loop.
                    jBuf.(size 0) <- jFirst.(size 0);
                    let jFinish = jFirst.(size 0) +. numoProblems.(size 0) in
                    while
                        #(fun h -> live h numoProblems /\ live h jTwiddle /\ live h jFirst /\ live h a /\ live h w /\ live h jBuf)
                        #(fun _ h -> live h numoProblems /\ live h jTwiddle /\ live h jFirst /\ live h a /\ live h w /\ live h jBuf)
                        (fun _ -> jBuf.(size 0) <. jFinish)
                        (fun _ ->
                            let j:size_t = jBuf.(size 0) in
                            let jNumo:size_t = j +. numoProblems.(size 0) in
                            let ajNumo:elem = a.(jNumo) in // a[j + NumoProblems]
                            let temp:elem = reduce I64.((elem_to_int64 wj) *^ (elem_to_int64 ajNumo)) in
                            let aj:elem = a.(j) in
                            a.(jNumo) <- aj -^ temp;
                            a.(j) <- temp +^ aj;
			    jBuf.(size 0) <- j +. size 1
                        );
                    jFirst.(size 0) <- jBuf.(size 0) +. numoProblems.(size 0)
                );
            numoProblems.(size 0) <- numoProblems.(size 0) >>. size 1;
            pop_frame()
        );
    pop_frame()

val nttinv:
    a: poly
  -> w: poly
  -> Stack unit
    (requires fun h -> live h a /\ live h w /\ disjoint a w)
    (ensures fun h0 _ h1 -> modifies1 a h0 h1)

let nttinv a w =
    push_frame();
    let numoProblems = create (size 1) (size 1) in
    let jTwiddle = create (size 1) (size 0) in

    while // Outermost for loop
        #(fun h -> live h numoProblems /\ live h jTwiddle /\ live h a /\ live h w)
        #(fun _ h -> live h numoProblems /\ live h jTwiddle /\ live h a /\ live h w)
        (fun _ -> numoProblems.(size 0) <. params_n)
        (fun _ ->
            push_frame();
            let jBuf = create (size 1) (size 0) in
            let jFirst = create (size 1) (size 0) in
            let cond () : Stack bool
              (requires fun h -> live h jFirst)
              (ensures fun h0 _ h1 -> live h1 jFirst)
            = jFirst.(size 0) <. params_n in
            while // Middle for loop
                #(fun h -> live h numoProblems /\ live h jTwiddle /\ live h jBuf /\ live h jFirst /\ live h a /\ live h w)
                #(fun _ h -> live h numoProblems /\ live h jTwiddle /\ live h jBuf /\ live h jFirst /\ live h a /\ live h w)
                cond
                (fun _ ->
                    let jTwiddleVal = jTwiddle.(size 0) in
                    let wj:elem = w.(jTwiddleVal) in
                    jTwiddle.(size 0) <- jTwiddleVal +. (size 1);
                    // Innermost for loop. Have to use a while because the middle for loop's increment depends on the
                    // final value of j from each inner for loop, so its scope can't be constrained to the for loop.
                    jBuf.(size 0) <- jFirst.(size 0);
                    let jFinish = jFirst.(size 0) +. numoProblems.(size 0) in
                    while
                        #(fun h -> live h numoProblems /\ live h jTwiddle /\ live h jFirst)
                        #(fun _ h -> live h numoProblems /\ live h jTwiddle /\ live h jFirst)
                        (fun _ -> jBuf.(size 0) <. jFinish)
                        (fun _ ->
                            let j:size_t = jBuf.(size 0) in
                            let jNumo = j +. numoProblems.(size 0) in
                            let temp:elem = a.(j) in
                            let ajNumo:elem = a.(jNumo) in
			    if numoProblems.(size 0) = size 16
			    then ( a.(j) <- barr_reduce ( temp +^ ajNumo ) )
			    else ( a.(j) <- temp +^ ajNumo );
			    let diff = temp -^ ajNumo in
                            a.(jNumo) <- reduce I64.((elem_to_int64 wj) *^ (elem_to_int64 diff));
			    jBuf.(size 0) <- j +. size 1
                        );
                    jFirst.(size 0) <- jBuf.(size 0) +. numoProblems.(size 0)
                );
            numoProblems.(size 0) <- numoProblems.(size 0) *. size 2;
            pop_frame()
        );

    for 0ul (params_n /. size 2)
    (fun h _ -> live h a)
    (fun i ->
        let ai = a.(i) in
	a.(i) <- reduce I64.(params_r *^ (elem_to_int64 ai))
    );

    pop_frame()

// When the Frodo code creates arrays of constants like this, it uses createL_global, which creates an
// immutable buffer. But this screws up subtyping with poly, which is sometimes mutable. Nik tells us
// there's no good way to do this because, unlike const parameters in C, guarantees like this go both ways
// and we'd essentially be asking the world never to mutate a poly, which is obviously not going to work. So
// we use createL, which makes it mutable, but we just never change it.
private let zeta: poly = createL zeta_list

val poly_ntt:
    x_ntt: poly
  -> x: poly
  -> Stack unit
    (requires fun h -> live h x_ntt /\ live h x /\ disjoint x_ntt x)
    (ensures fun h0 _ h1 -> modifies1 x h0 h1)

let poly_ntt x_ntt x =
    push_frame();
    for 0ul params_n
    (fun h _ -> live h x_ntt /\ live h x)
    (fun i ->
        x_ntt.(i) <- (x.(i))
    );

    ntt x_ntt zeta;
    pop_frame()

val poly_pointwise:
    result: poly
  -> x: poly
  -> y: poly
  -> Stack unit
    (requires fun h -> live h result /\ live h x /\ live h y)
    (ensures fun h0 _ h1 -> modifies1 result h0 h1)

let poly_pointwise result x y =
    push_frame();
    for (size 0) params_n
    (fun h _ -> live h result /\ live h x /\ live h y)
    (fun i ->
        let xi:elem = x.(i) in
        let yi:elem = y.(i) in
        result.(i) <- reduce I64.( (elem_to_int64 xi) *^ (elem_to_int64 yi) )
    );
    pop_frame()

private let zetainv: poly = createL zetainv_list

// Unlike the reference code, this version of poly_mul assumes both arguments are in NTT form.
val poly_mul:
    result: poly
  -> x: poly
  -> y: poly
  -> Stack unit
    (requires fun h -> live h result /\ live h x /\ live h y)
    (ensures fun h0 _ h1 -> modifies1 result h0 h1)

let poly_mul result x y =
    poly_pointwise result x y;
    nttinv result zetainv

val poly_add:
    result: poly
  -> x: poly
  -> y: poly
  -> Stack unit
    (requires fun h -> live h result /\ live h x /\ live h y /\ disjoint result x /\ disjoint result y /\ disjoint x y)
    (ensures fun h0 _ h1 -> modifies1 result h0 h1)

let poly_add result x y =
    push_frame();
    for 0ul params_n
    (fun h _ -> live h result /\ live h x /\ live h y)
    (fun i ->
        result.(i) <- x.(i) +^ y.(i)
    );
    pop_frame()

val poly_add_correct:
    result: poly
  -> x: poly
  -> y: poly
  -> Stack unit
    (requires fun h -> live h result /\ live h x /\ live h y /\ disjoint result x /\ disjoint result y /\ disjoint x y)
    (ensures fun h0 _ h1 -> modifies1 result h0 h1)

let poly_add_correct result x y =
    push_frame();
    for 0ul params_n
    (fun h _ -> live h result /\ live h x /\ live h y)
    (fun i ->
        result.(i) <- x.(i) +^ y.(i);
	result.(i) <- result.(i) +^ ((result.(i) >>^ (size elem_n -. size 1)) &^ params_q);
	result.(i) <- result.(i) -^ params_q;
	result.(i) <- result.(i) +^ ((result.(i) >>^ (size elem_n -. size 1)) &^ params_q)
    );
    pop_frame()

val poly_sub_correct:
    result: poly
  -> x: poly
  -> y: poly
  -> Stack unit
    (requires fun h -> live h result /\ live h x /\ live h y)
    (ensures fun h0 _ h1 -> modifies1 result h0 h1)

let poly_sub_correct result x y =
    push_frame();
    for 0ul params_n
    (fun h _ -> live h result /\ live h x /\ live h y)
    (fun i ->
        result.(i) <- x.(i) -^ y.(i);
	result.(i) <- result.(i) +^ ((result.(i) >>^ (size elem_n -. size 1)) &^ params_q)
    );
    pop_frame()

val poly_sub_reduce:
    result: poly
  -> x: poly
  -> y: poly
  -> Stack unit
    (requires fun h -> live h result /\ live h x /\ live h y)
    (ensures fun h0 _ h1 -> modifies1 result h0 h1)

let poly_sub_reduce result x y =
    push_frame();
    for 0ul params_n
    (fun h _ -> live h result /\ live h x /\ live h y)
    (fun i ->
        let diff = x.(i) -^ y.(i) in
        result.(i) <- reduce I64.(params_r *^ (elem_to_int64 diff))
    );
    pop_frame()