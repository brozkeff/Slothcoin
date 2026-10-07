// Focused build5 regressions. Run with make -f makefile.unix check-security.
#include "key.h"
#include "crypter.h"
#include "bignum.h"
#include "main.h"
#include <iostream>
#include <stdexcept>

LockedPageManager LockedPageManager::instance;

static void Check(bool ok, const char* message)
{
    if (!ok) throw std::runtime_error(message);
}

int main()
{
    try {
        // The scalar 1 has the standard P-256 generator as its public key.
        CSecret secret(32, 0);
        secret[31] = 1;
        CKey key;
        Check(key.IsNull(), "new key must be empty");
        Check(key.SetSecret(secret), "import private key");
        Check(key.IsValid(), "imported private/public key consistency");
        Check(HexStr(key.GetPubKey().Raw()) ==
            "046b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296"
            "4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5",
            "P-256 public key encoding");
        bool compressed;
        Check(key.GetSecret(compressed) == secret && !compressed, "private key round trip");
        CKey copied(key), assigned;
        assigned = key;
        Check(copied.IsValid() && assigned.IsValid(), "copy private key state and curve");
        std::vector<unsigned char> signature;
        uint256 hash(42);
        Check(copied.Sign(hash, signature), "sign copied key");
        CKey verifier;
        Check(verifier.SetPubKey(key.GetPubKey()), "load public key");
        Check(verifier.Verify(hash, signature), "verify signature");
        // Independently construct a deterministic legacy signature: private scalar
        // and nonce both 1, R = the P-256 generator, challenge hashed by SPH.
        std::vector<unsigned char> pointAndMessage = key.GetPubKey().Raw();
        std::vector<unsigned char> message = hash.toVch();
        pointAndMessage.insert(pointAndMessage.end(), message.begin(), message.end());
        uint256 challengeHash = HashKeccak(pointAndMessage.begin(), pointAndMessage.end());
        CryptoPP::Integer order("0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551");
        CryptoPP::Integer challenge((unsigned char*)&challengeHash, 32);
        challenge %= order;
        CryptoPP::Integer response = (CryptoPP::Integer::One() - challenge) % order;
        std::vector<unsigned char> legacySignature(64);
        challenge.Encode(legacySignature.data(), 32);
        response.Encode(legacySignature.data() + 32, 32);
        Check(verifier.Verify(hash, legacySignature), "legacy SPH/P-256 signature compatibility");
        Check(!verifier.Verify(uint256(43), signature), "reject wrong message");
        Check(!verifier.Sign(hash, signature), "public key cannot sign");
        for (size_t length = 0; length < 70; ++length) {
            if (length != 64)
                Check(!verifier.Verify(hash, std::vector<unsigned char>(length)), "reject malformed signature length");
        }
        Check(!verifier.SetPubKey(CPubKey()), "reject empty public key");
        Check(!verifier.SetPubKey(CPubKey(std::vector<unsigned char>(65, 0))), "reject invalid point");
        Check(assigned.SetPubKey(key.GetPubKey()), "replace private with public key");
        Check(!assigned.Sign(hash, signature), "discard replaced private key");
        CSecret zero(32, 0), tooLarge(32, 255);
        Check(!key.SetSecret(zero) && !key.SetSecret(tooLarge), "reject invalid private scalars");
        key.Reset();
        Check(key.IsNull() && !key.Sign(hash, signature), "reset clears key state");
        key.MakeNewKey(false);
        Check(key.IsValid(), "generated nonzero private key");

        // Legacy SHA3 is Keccak, whose empty-message digest is well known.
        CryptoPP::Keccak_256 keccak;
        unsigned char digest[32];
        keccak.Final(digest);
        Check(HexStr(digest, digest + 32) ==
            "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470", "legacy Keccak padding");
        std::vector<unsigned char> empty;
        uint256 sphHash = HashKeccak(empty.begin(), empty.end());
        Check(HexStr((unsigned char*)&sphHash, (unsigned char*)&sphHash + 32) == HexStr(digest, digest + 32),
            "SPH and Crypto++ Keccak agree");

        CBigNum number;
        Check(number.SetCompact(0x1d00ffff).GetCompact() == 0x1d00ffff, "difficulty compact encoding");
        Check((CBigNum(123456) * CBigNum(789) / CBigNum(789)).getint() == 123456, "bignum arithmetic");
        Check(CBigNum(-42).ToString() == "-42", "negative bignum");
        CBigNum encoded(number.getvch());
        Check(encoded == number, "bignum serialized round trip");

        int64 total = MAX_MONEY - 1;
        Check(AddMoney(total, 1) && total == MAX_MONEY, "accept exact money limit");
        Check(!AddMoney(total, 1) && total == MAX_MONEY, "reject money overflow without mutation");
        Check(!AddMoney(total, MAX_MONEY), "reject signed-overflow sum before addition");
        total = 0;
        Check(!AddMoney(total, -1) && total == 0, "reject negative money");
        CTransaction transaction;
        transaction.vout.push_back(CTxOut(MAX_MONEY, CScript()));
        Check(transaction.GetValueOut() == MAX_MONEY, "transaction exact money limit");
        transaction.vout.push_back(CTxOut(MAX_MONEY, CScript()));
        bool rejected = false;
        try { transaction.GetValueOut(); }
        catch (const std::runtime_error&) { rejected = true; }
        Check(rejected, "transaction overflow output sum rejected");

        CCrypter crypter;
        CKeyingMaterial master(32, 7), plaintext(32, 9), recovered;
        std::vector<unsigned char> iv(32, 3), ciphertext;
        Check(crypter.SetKey(master, iv), "set encryption key");
        Check(crypter.Encrypt(plaintext, ciphertext) && ciphertext.size() == 48, "encrypt secret");
        Check(crypter.Decrypt(ciphertext, recovered) && recovered == plaintext, "decrypt secret");
        ciphertext.back() ^= 1;
        Check(!crypter.Decrypt(ciphertext, recovered) && recovered.empty(), "clear failed plaintext");
        Check(!crypter.Decrypt(empty, recovered), "reject empty ciphertext");
        Check(recovered.empty(), "empty ciphertext clears output");
        Check(crypter.Encrypt(CKeyingMaterial(), ciphertext), "encrypt empty plaintext");
        Check(crypter.Decrypt(ciphertext, recovered) && recovered.empty(), "empty plaintext round trip");
        SecureString passphrase;
        Check(crypter.SetKeyFromPassphrase(passphrase, std::vector<unsigned char>(8, 1), 1, 0), "empty passphrase memory safety");
        Check(!crypter.SetKeyFromPassphrase(passphrase, std::vector<unsigned char>(8, 1), 0, 0), "reject zero KDF rounds");
        Check(!crypter.Encrypt(plaintext, ciphertext), "invalid KDF clears prior encryption key");
        std::cout << "Build5 security regressions passed\n";
        return 0;
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
