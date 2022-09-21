from starkware.cairo.common.math_cmp import is_in_range
from starkware.cairo.common.uint256 import Uint256

func warp_external_input_check_int8{range_check_ptr}(number: felt) :
    let limit = 2 ** 8 - 1
    let (res,) = is_in_range(number, 0, limit) 
    assert res = 1
    return ()
end

func warp_external_input_check_int256{range_check_ptr}(number: Uint256) :
    let limit = 2 ** 128 - 1
    let (res,) = is_in_range(number.high, 0, limit)
    assert res = 1
    return ()
end

