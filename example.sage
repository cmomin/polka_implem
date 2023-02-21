#Copyright 2023 UCLouvain
#
#Permission to use, copy, modify, and/or distribute this software for any
#purpose with or without fee is hereby granted.
#
#THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
#REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
#AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
#INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
#LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
#OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
#PERFORMANCE OF THIS SOFTWARE

from polka import keygen, encrypt, decrypt
from polka_utils import PRNG

# Example of usage
import numpy as np

# Example configuration
lM = 19
lNonce = 16
seed_prng = None # Fix a value here to ensure reproducable result

# Generation of the PRNG instance. 
prng = PRNG(seed=seed_prng)

# Key generation
(pk, sk) = keygen(prng)    

# Encryption for a random M and nonce
M = bytes(np.random.randint(0,256,size=lM,dtype=np.uint8).tolist())
nonce = bytes(np.random.randint(0,256,size=lNonce,dtype=np.uint8).tolist())

# Encryption
c = encrypt(prng, pk, M, nonce)

# Decryption
Md = decrypt(prng, pk, sk, c, nonce)

assert Md == M
print("Enc-dec ok!")

