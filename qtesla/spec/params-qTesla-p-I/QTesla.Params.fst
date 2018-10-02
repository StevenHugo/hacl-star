module QTesla.Params

open Lib.IntTypes

let params_lambda = 95 // security parameter
let params_kappa = 32 // output length of hash function in bytes (spec lists them in bits, so convert)
let params_n = 1024 // Dimension
let params_k = 4       // #R-LWE samples (number of polynomials in e, t, a, etc)
let params_q = 485978113 // modulus
let params_h = 25      // # of nonzero entries of output elements of Enc
let params_Le = 554    // bound on e_i for checkE
let params_Ls = 554    // bound on s for checkS
let params_B = 2097151 // interval the randomness is chosing from during signing
let params_d = 22      // number of rounded bits
let params_bGenA = 108 // number of blocks requested to SHAKE128 for GenA

let params_rateXOF = 168
let params_xof = Spec.SHA3.shake128        // extendable output function used in PRF1: use shake128 or shake256 depending on parameters chosen
let params_hash_shake = Spec.SHA3.shake128 // hash function used in hash H: use shake128 or shake256 depending on parameters chosen

// See the GenerateNTTConstants-Magma.txt script for computing these five
// constants used in NTT.
let computed_phi = 250428822
let computed_omega = 483976553
let computed_phi_inv = 195194787
let computed_omega_inv = 67220789
let computed_n_inv = 485503525
