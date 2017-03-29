/* This file was auto-generated by KreMLin! */
#ifndef __SHA2_256_H
#define __SHA2_256_H



#include "kremlib.h"
#include "testlib.h"

typedef uint8_t uint8_t;

typedef uint32_t uint32_t;

typedef uint64_t uint64_t;

typedef uint8_t suint8_t;

typedef uint32_t suint32_t;

typedef uint64_t suint64_t;

typedef uint32_t *suint32_p;

typedef uint8_t *suint8_p;

typedef uint8_t uint8_t0;

typedef uint32_t uint32_t0;

typedef uint64_t uint64_t0;

typedef uint8_t suint8_t0;

typedef uint32_t suint32_t0;

typedef uint64_t suint64_t0;

typedef uint32_t *suint32_p0;

typedef uint8_t *suint8_p0;

typedef struct {
  uint32_t fst;
  uint8_t *snd;
}
K___uint32_t_uint8_t_;

typedef uint8_t uint8_t1;

typedef uint32_t uint32_t1;

typedef uint64_t uint64_t1;

typedef uint8_t suint8_t1;

typedef uint32_t suint32_t1;

typedef uint64_t suint64_t1;

typedef uint32_t *suint32_p1;

typedef uint8_t *suint8_p1;

extern uint32_t hash_hashsize_256;

extern uint32_t hash_blocksize_256;

extern uint32_t hash_size_state_256;

void sha2_init_256(uint32_t *state);

void sha2_update_256(uint32_t *state, uint8_t *data_8);

void sha2_update_multi_256(uint32_t *state, uint8_t *data, uint32_t n1);

void sha2_update_last_256(uint32_t *state, uint8_t *data, uint32_t len);

void sha2_finish_256(uint32_t *state, uint8_t *hash1);

void sha2_256(uint8_t *hash1, uint8_t *input, uint32_t len);
#endif
