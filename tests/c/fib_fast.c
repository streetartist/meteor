#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

// -------------------- BigInt Implementation --------------------
// Base for internal storage is 2^64 (uint64_t)
typedef struct {
    uint64_t *digits;
    int size;       // Number of used digits
    int capacity;   // Allocated size
} BigInt;

BigInt* bi_new(int capacity) {
    if (capacity < 1) capacity = 1;
    BigInt *bi = (BigInt*)malloc(sizeof(BigInt));
    bi->digits = (uint64_t*)calloc(capacity, sizeof(uint64_t));
    bi->size = 1; // Default 0 has size 1
    bi->capacity = capacity;
    return bi;
}

void bi_free(BigInt *bi) {
    if (bi) {
        free(bi->digits);
        free(bi);
    }
}

BigInt* bi_from_int(uint64_t val) {
    BigInt *bi = bi_new(1);
    bi->digits[0] = val;
    bi->size = (val == 0) ? 1 : 1; // 0 has size 1
    return bi;
}

BigInt* bi_copy(const BigInt *src) {
    BigInt *dest = bi_new(src->size);
    memcpy(dest->digits, src->digits, src->size * sizeof(uint64_t));
    dest->size = src->size;
    return dest;
}

// Remove leading zeros
void bi_trim(BigInt *bi) {
    while (bi->size > 1 && bi->digits[bi->size - 1] == 0) {
        bi->size--;
    }
}

// Optimized Addition: c = a + b
BigInt* bi_add(const BigInt *a, const BigInt *b) {
    int max_size = (a->size > b->size ? a->size : b->size) + 1;
    BigInt *res = bi_new(max_size);
    res->size = max_size;

    uint64_t carry = 0;
    for (int i = 0; i < max_size; i++) {
        uint64_t va = (i < a->size) ? a->digits[i] : 0;
        uint64_t vb = (i < b->size) ? b->digits[i] : 0;
        
        // Use standard overflow check for addition
        uint64_t sum = va + vb;
        uint64_t new_carry = (sum < va); // Check overflow of va + vb
        
        uint64_t total = sum + carry;
        if (total < sum) new_carry = 1; // Check overflow of sum + carry
        
        res->digits[i] = total;
        carry = new_carry;
    }
    bi_trim(res);
    return res;
}

// Subtraction: c = a - b (Assume a >= b)
BigInt* bi_sub(const BigInt *a, const BigInt *b) {
    BigInt *res = bi_new(a->size);
    res->size = a->size;

    uint64_t borrow = 0;
    for (int i = 0; i < a->size; i++) {
        uint64_t va = a->digits[i];
        uint64_t vb = (i < b->size) ? b->digits[i] : 0;

        uint64_t diff = va - vb - borrow;
        if (va < vb + borrow) { // Check borrow condition CAREFULLY. 
            // Correct way: if va < vb, we borrowed. Or if borrowing from previous made it less.
             // (va - vb) wraps if va < vb. 
            borrow = 1;
        } else {
             borrow = 0;
        }
        res->digits[i] = diff;
    }
    bi_trim(res);
    return res;
}

// Multiplication: c = a * b (O(N^2) naive for simplicity, still fast due to C speed)
BigInt* bi_mul(const BigInt *a, const BigInt *b) {
    if ((a->size == 1 && a->digits[0] == 0) || (b->size == 1 && b->digits[0] == 0)) {
        return bi_from_int(0);
    }

    int res_size = a->size + b->size;
    BigInt *res = bi_new(res_size);
    res->size = res_size; 

    // Use uint128_t for intermediate product if compiler supports it (GCC/Clang do)
    // standard 64-bit multiplication: (hi, lo) = u64 * u64
    for (int i = 0; i < a->size; i++) {
        uint64_t carry = 0;
        for (int j = 0; j < b->size; j++) {
            unsigned __int128 product = (unsigned __int128)a->digits[i] * b->digits[j] 
                                      + res->digits[i+j] + carry;
            res->digits[i+j] = (uint64_t)product;
            carry = (uint64_t)(product >> 64);
        }
        res->digits[i + b->size] += carry;
    }
    bi_trim(res);
    return res;
}

// Base 10^19 Optimization for Printing
#define TEN_19 10000000000000000000ULL

void bi_print(const BigInt *bi) {
    if (bi->size == 1 && bi->digits[0] == 0) {
        printf("0\n");
        return;
    }

    // Since we need to output in Base 10, we'll convert 2^64 base to 10^19 base.
    // This requires a division loop, but we can process much faster.
    
    // Copy bi to a temporary work buffer (we will consume it)
    BigInt *work = bi_copy(bi);
    
    // Array to store 10^19 digits
    // Estimate size: 2^64 ~= 1.8e19. Each uint64 word is roughly 1 '10^19' block.
    // So output blocks count roughly equals input size.
    int cap = work->size * 2 + 10;
    uint64_t *dec_blocks = (uint64_t*)malloc(cap * sizeof(uint64_t));
    int dec_len = 0;

    while (!(work->size == 1 && work->digits[0] == 0)) {
        // Divide work by 10^19
        uint64_t remainder = 0;
        for (int i = work->size - 1; i >= 0; i--) {
            unsigned __int128 cur = work->digits[i] + ((unsigned __int128)remainder << 64);
            work->digits[i] = (uint64_t)(cur / TEN_19);
            remainder = (uint64_t)(cur % TEN_19);
        }
        bi_trim(work);
        dec_blocks[dec_len++] = remainder;
    }

    // Print reversed
    if (dec_len > 0) {
        printf("%llu", dec_blocks[dec_len - 1]); // First block: no padding
        for (int i = dec_len - 2; i >= 0; i--) {
            printf("%019llu", dec_blocks[i]); // Padding for inner blocks
        }
    } else {
        printf("0");
    }
    printf("\n");

    bi_free(work);
    free(dec_blocks);
}

// -------------------- Fast Fibonacci --------------------
// F(2k) = F(k) * (2*F(k+1) - F(k))
// F(2k+1) = F(k+1)^2 + F(k)^2

BigInt* fib_fast(int n) {
    if (n == 0) return bi_from_int(0);
    if (n == 1) return bi_from_int(1);

    BigInt *a = bi_from_int(0); // F(k)
    BigInt *b = bi_from_int(1); // F(k+1)

    // Find highest set bit
    int i = 31;
    while ((i >= 0) && !((n >> i) & 1)) {
        i--;
    }
    
    // We can skip the very first bit because we setup a=0, b=1 corresponding to "current fib(0), fib(1)"? 
    // Wait, let's follow standard loop:
    // Start from MSB.
    
    // Actually, typical algo starts with k=0 (a=0, b=1). 
    // And for each bit from MSB to LSB:
    //   Double k: (Calculate F(2k), F(2k+1))
    //   If bit is set: k -> 2k+1 (Move to F(2k+1), F(2k+2))
    
    // Let's iterate i from highest bit - 1 down to 0.
    // Initial state k=1 (since we skipped MSB which is always 1 for n>0)
    // a = F(1) = 1, b = F(2) = 1 is often better start?
    // Let's stick to user's logic: Start a=0 (F0), b=1 (F1). Loop all bits.
    
    // User's logic was:
    // i = 30; started = false;
    // loop i >= 0:
    //   bit = (n>>i)&1
    //   if bit==1 started=true
    //   if started:
    //      calc c=F(2k), d=F(2k+1)
    //      if bit==0: a=c, b=d
    //      else: a=d, b=c+d
    
    // Let's replicate EXACTLY the logic from fib_fast.met
    
    bi_free(a); bi_free(b);
    a = bi_from_int(0);
    b = bi_from_int(1);
    
    int bit_idx = 30; // Assuming n fits in 31 bits
    bool started = false;
    
    while (bit_idx >= 0) {
        int bit = (n >> bit_idx) & 1;
        if (bit) started = true;
        
        if (started) {
            // c = a * (2*b - a)
            // d = a*a + b*b
            
            // temp1 = 2*b
            BigInt *two_b = bi_add(b, b);
            // temp2 = 2*b - a
            BigInt *temp2 = bi_sub(two_b, a);
            // c = a * temp2
            BigInt *c = bi_mul(a, temp2);

            bi_free(two_b);
            bi_free(temp2);

            // a_sq = a*a
            BigInt *a_sq = bi_mul(a, a);
            // b_sq = b*b
            BigInt *b_sq = bi_mul(b, b);
            // d = a_sq + b_sq
            BigInt *d = bi_add(a_sq, b_sq);

            bi_free(a_sq);
            bi_free(b_sq);
            
            if (bit == 0) {
                bi_free(a); a = c;
                bi_free(b); b = d;
            } else {
                // Return to (d, c+d)
                BigInt *c_plus_d = bi_add(c, d);
                bi_free(a); a = d;
                bi_free(b); b = c_plus_d;
                bi_free(c); // c was used for sum, now free
            }
        }
        bit_idx--;
    }
    
    bi_free(b);
    return a;
}

int main() {
    int n = 10000000;

    BigInt *res = fib_fast(n);
    printf("Fibonacci result:\n");
    bi_print(res);
    bi_free(res);

    return 0;
}
