from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_in_range

func warp_add256{range_check_ptr} (a: Uint256, b: Uint256) -> (uint256: Uint256) :
    let limit = 2 ** 128 - 1

    if a.high == 0 and b.high == 0:
        let sum = a.low + b.low
        let (res,) = is_in_range(sum, 0, limit)
        if res == 0 :
            let aux = sum - limit
            return (Uint256(0, aux),)
        else : 
            return (Uint256(sum, 0),)
        end
    end
    if a.high == 0 and b.high != 0 :
        let (res,) = is_in_range(a.low + b.high, 0, limit) 
        assert res = 1
        let sum = a.low + b.high
        return (Uint256(0, sum),)
    end
    if a.high != 0 and b.high == 0 :
        let (res,) = is_in_range(a.high + b.low, 0, limit)
        assert res = 1
        let sum = a.high + b.low
        return (Uint256(0, sum),)
    end
    if a.high != 0 and b.high != 0 :
        let (res,) = is_in_range(a.high + b.high, 0, limit) 
        assert res = 1
        let sum = a.high + b.high
        return (Uint256(0, sum),)
    end
    return (Uint256(0,0),)
end