// Copyright (c) 2014 SlothCoin Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.
#ifndef H_SlothCoin_SCHNORR
#define H_SlothCoin_SCHNORR

#include <string>
#include <iostream>
using namespace std;

#include <crypto++/osrng.h>      // Random Number Generator
#include <crypto++/eccrypto.h>   // Elliptic Curve
#include <crypto++/ecp.h>        // F(p) EC
#include <crypto++/integer.h>    // Integer
#include <crypto++/keccak.h>		 // SHA3

#define SCHNORR_SECRET_KEY_SIZE 32
#define SCHNORR_SIG_SIZE 32
#define SCHNORR_PUBLIC_KEY_COMPRESSED_SIZE 33
#define SCHNORR_PUBLIC_KEY_UNCOMPRESSED_SIZE 65

#endif
