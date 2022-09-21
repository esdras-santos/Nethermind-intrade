from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_in_range


func warp_uint256{range_check_ptr}(number: felt) -> (uint256: Uint256) : 
    let limit = (2 ** 128) - 1
    let (res,) = is_in_range(number, 0, limit)
    if  res == 1:
        return (Uint256(number, 0),)
    else :
        let aux = number - limit
        let (res,) = is_in_range(aux, 0, limit) 
        assert  res = 1
        return (Uint256(0, aux),)
    end     
end