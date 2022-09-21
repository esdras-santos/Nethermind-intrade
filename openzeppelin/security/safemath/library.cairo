# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.4.0b (security/safemath/library.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_check,
    uint256_add,
    uint256_sub,
    uint256_mul,
    uint256_unsigned_div_rem,
    uint256_le,
    uint256_lt,
    uint256_eq,
)

namespace SafeUint256 :
    func add{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        a: Uint256, b: Uint256
    ) -> (c: Uint256) :
        uint256_check(a)
        uint256_check(b)
        let (c: Uint256, is_overflow) = uint256_add(a, b)
        with_attr error_message("SafeUint256: addition overflow") :
            assert is_overflow = FALSE
        end
        return (c=c)
    end

    func sub_le{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        a: Uint256, b: Uint256
    ) -> (c: Uint256) :
        alloc_locals
        uint256_check(a)
        uint256_check(b)
        let (is_le) = uint256_le(b, a)
        with_attr error_message("SafeUint256: subtraction overflow") :
            assert is_le = TRUE
        end
        let (c: Uint256) = uint256_sub(a, b)
        return (c=c)
    end

    func sub_lt{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        a: Uint256, b: Uint256
    ) -> (c: Uint256) :
        alloc_locals
        uint256_check(a)
        uint256_check(b)

        let (is_lt) = uint256_lt(b, a)
        with_attr error_message("SafeUint256: subtraction overflow or the difference equals zero") :
            assert is_lt = TRUE
        end
        let (c: Uint256) = uint256_sub(a, b)
        return (c=c)
    end

    func mul{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        a: Uint256, b: Uint256
    ) -> (c: Uint256) :
        alloc_locals
        uint256_check(a)
        uint256_check(b)
        let (a_zero) = uint256_eq(a, Uint256(0, 0))
        if a_zero == TRUE :
            return (c=a)
        end

        let (b_zero) = uint256_eq(b, Uint256(0, 0))
        if b_zero == TRUE :
            return (c=b)
        end

        let (c: Uint256, overflow: Uint256) = uint256_mul(a, b)
        with_attr error_message("SafeUint256: multiplication overflow") :
            assert overflow = Uint256(0, 0)
        end
        return (c=c)
    end

    func div_rem{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        a: Uint256, b: Uint256
    ) -> (c: Uint256, rem: Uint256) :
        alloc_locals
        uint256_check(a)
        uint256_check(b)

        let (is_zero) = uint256_eq(b, Uint256(0, 0))
        with_attr error_message("SafeUint256: divisor cannot be zero") :
            assert is_zero = FALSE
        end

        let (c: Uint256, rem: Uint256) = uint256_unsigned_div_rem(a, b)
        return (c=c, rem=rem)
    end
end