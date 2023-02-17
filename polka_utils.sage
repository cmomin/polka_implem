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

import numpy as np

class Params:
    '''
    Object to hold the parameters of the instance implemented.

    The variable names have been chosen accordingly to the paper notations.
    '''
    def __init__(self, version="16"):
        # Set the version params
        if version=="16":
            self.__set_params(10,59393,5,2,1)
        else:
            raise ValueError("Version not handled.")

        # Create the Univariate Quotient Polynomial Ring in x over
        # Finite Field of size q with modulus x^n + 1
        # (refered as R_q in the paper) 
        self.__set_R_q()

        # Set the version
        self.__version = version

    def __set_params(
            self,
            logn, 
            q,
            p,
            k,
            B
            ):
        self.__logn = logn
        self.__n = 0b1 << self.__logn
        self.__q = q
        self.__p = p
        self.__k = k
        self.__B = B

    def __set_R_q(self):
        Zq = GF(self.q)
        A = PolynomialRing(Zq, 'g')
        g = A.gen()
        R = A.quotient(g^self.n + 1, 'x')
        self.__R = R
        self.__A = A
        
    @property
    def version(self):
        return self.__version

    @property
    def n(self):
        return self.__n

    @property
    def q(self):
        return self.__q

    @property
    def p(self):
        return self.__p

    @property
    def k(self):
        return self.__k

    @property
    def B(self):
        return self.__B

    @property
    def R(self):
        return self.__R

    @property
    def A(self):
        return self.__A

def embedding(pol,mod):
    '''
    In POLKA, polynomials over Z_q[X] (of degre n-1) are represented as
    an n-dimensional vector with coefficients in the range 
    [-(mod-1)/2 ; (mod-1)/2]

    This function convert a list of coefficient over the range [0; mod[
    to the range [-(mod-1)/2 ; (mod-1)/2].
    '''
    return [(int(e) - (0 if int(e)<=(mod-1)//2 else mod)) for e in pol]      

# A PRNG instance used by the Polka implem
# rely on the class Params in order to access the instance 
# params considered for the desired version.
class PRNG:
    '''
    A PRNG instance used to generate the randomness in the different steps 
    of the POLKA scheme. 

    Every instance can be seeded independently and their usage is fixed to a 
    single parameter set of Polka (as specified by 'version'). 
    '''
    def __init__(self, version="16", seed=None):
        self.cfg = Params(version)
        self.set_seed(seed)

    def set_seed(self, seed):
        '''
        Set the seed for the PRNG instance. Overwrite current PRNG state.
        '''
        self.__rs = np.random.RandomState(seed)

    def __sample_binomial(self):
        '''
        Sample of polynomial in R_q with with coefficients
        drawn for a centered binomial distribution of parameter k, with 
        the sample taken modulo 3 (as detailed in the paper). 
        '''
        ret = []
        for _ in range(self.cfg.n):
            a = self.__rs.randint(2, size=self.cfg.k)
            b = self.__rs.randint(2, size=self.cfg.k)
            ret.append((sum(a) - sum(b)) % 3)
        return self.cfg.R(embedding(ret,3))

    def sample_error(self):
        '''
        Sample an error polynomial according to the version error
        distribution. 
        '''
        if self.cfg.version=="16":
            return self.__sample_binomial()
        else:
            raise ValueError("Wrong instance configuration. Version {} not handled".format(self.cfg.Version))

    def random_pol(self):
        '''
        Generate a random (uniform) polynomial over R_q.
        '''
        coefs = self.__rs.randint(0,self.cfg.q,size=self.cfg.n,dtype=int).tolist()
        return self.cfg.R(coefs)

    @property
    def version(self):
        return self.cfg.version

    def randomness_keygen(self):
        '''
        Generate the randomness for the keygen step of POLKA.

        Provided as a wrapper function in order to ensure order 
        of random sampling with (potentially) seeded PRNG for reproduciability 
        purpose. 
        '''
        a = self.random_pol()
        s = self.sample_error()
        e = self.sample_error()
        return (a,s,e)

    def randomness_enc_dec(self):
        '''
        Generate the randomness for the encryption/decryption step of POLKA.

        Provided as a wrapper function in order to ensure order 
        of random sampling with (potentially) seeded PRNG for reproduciability 
        purpose. 
        '''
        r = self.sample_error()
        e1 = self.sample_error()
        e2 = self.sample_error()
        return (r, e1, e2)
