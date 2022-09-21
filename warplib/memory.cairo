from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.dict import dict_read, dict_write
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_le,
    uint256_lt,
    uint256_mul,
)
from warplib.maths.utils import felt_to_uint256, narrow_safe


func wm_read_felt{warp_memory: DictAccess*}(loc: felt) -> (val: felt) :
    let (res) = dict_read{dict_ptr=warp_memory}(loc)
    return (res,)
end

func wm_read_256{warp_memory: DictAccess*}(loc: felt) -> (val: Uint256) :
    let (low) = dict_read{dict_ptr=warp_memory}(loc)
    let (high) = dict_read{dict_ptr=warp_memory}(loc + 1)
    return (Uint256(low, high),)
end

func wm_write_felt{warp_memory: DictAccess*}(loc: felt, value: felt) -> (res: felt) :
    dict_write{dict_ptr=warp_memory}(loc, value)
    return (value,)
end

func wm_write_256{warp_memory: DictAccess*}(loc: felt, value: Uint256) -> (res: Uint256) :
    dict_write{dict_ptr=warp_memory}(loc, value.low)
    dict_write{dict_ptr=warp_memory}(loc + 1, value.high)
    return (value,)
end


func wm_index_static{range_check_ptr}(
    arrayLoc: felt, index: Uint256, width: Uint256, length: Uint256
) -> (loc: felt) :
    let (inRange) = uint256_lt(index, length)
    assert inRange = 1

    let (offset: Uint256, overflow: Uint256) = uint256_mul(index, width)
    assert overflow.low = 0
    assert overflow.high = 0

    let (arrayLoc256: Uint256) = felt_to_uint256(arrayLoc)
    let (res: Uint256, carry: felt) = uint256_add(arrayLoc256, offset)
    assert carry = 0

    let (loc: felt) = narrow_safe(res)
    return (loc,)
end

func wm_index_dyn{range_check_ptr, warp_memory: DictAccess*}(
    arrayLoc: felt, index: Uint256, width: Uint256
) -> (loc: felt) :
    alloc_locals
    let (length: Uint256) = wm_read_256(arrayLoc)
    let (inRange) = uint256_lt(index, length)
    assert inRange = 1

    let (offset: Uint256, overflow: Uint256) = uint256_mul(index, width)
    assert overflow.low = 0
    assert overflow.high = 0

    let (elementZeroPtr) = felt_to_uint256(arrayLoc + 2)
    let (res256: Uint256, carry) = uint256_add(elementZeroPtr, offset)
    assert carry = 0
    let (res) = narrow_safe(res256)

    return (res,)
end

func wm_new{range_check_ptr, warp_memory: DictAccess*}(len: Uint256, elemWidth: Uint256) -> (
    loc: felt
) :
    alloc_locals
    let (feltLength: Uint256, overflow: Uint256) = uint256_mul(len, elemWidth)
    assert overflow.low = 0
    assert overflow.high = 0

    let (feltLength: Uint256, carry: felt) = uint256_add(feltLength, Uint256(2, 0))
    assert carry = 0

    let (loc) = wm_alloc(feltLength)
    dict_write{dict_ptr=warp_memory}(loc, len.low)
    dict_write{dict_ptr=warp_memory}(loc + 1, len.high)
    return (loc,)
end

func wm_dyn_array_length{warp_memory: DictAccess*}(arrayLoc: felt) -> (len: Uint256) :
    let (low) = dict_read{dict_ptr=warp_memory}(arrayLoc)
    let (high) = dict_read{dict_ptr=warp_memory}(arrayLoc + 1)
    return (Uint256(low, high),)
end

func wm_bytes_new{range_check_ptr, warp_memory: DictAccess*}(len: Uint256) -> (loc: felt) :
    alloc_locals
    let (arrayLoc) = wm_alloc(len)
    let (loc) = wm_alloc(Uint256(5, 0))
    dict_write{dict_ptr=warp_memory}(loc, len.low)
    dict_write{dict_ptr=warp_memory}(loc + 1, len.high)
    dict_write{dict_ptr=warp_memory}(loc + 2, len.low)
    dict_write{dict_ptr=warp_memory}(loc + 3, len.high)
    dict_write{dict_ptr=warp_memory}(loc + 4, arrayLoc)

    return (loc,)
end

func wm_bytes_push{range_check_ptr, warp_memory: DictAccess*}(bytesLoc: felt, value: felt) -> (
    len: Uint256
) :
    alloc_locals

    let (length) = wm_read_256(bytesLoc)
    let (newLength, carry) = uint256_add(length, Uint256(1, 0))
    assert carry = 0

    dict_write{dict_ptr=warp_memory}(bytesLoc, newLength.low)
    dict_write{dict_ptr=warp_memory}(bytesLoc + 1, newLength.high)

    let (capacity) = wm_read_256(bytesLoc + 2)
    let (arrayLoc) = wm_read_felt(bytesLoc + 4)

    let (le) = uint256_lt(length, capacity)
    if le == 1 :
        let (arrayLoc256) = felt_to_uint256(arrayLoc)
        let (res: Uint256, carry: felt) = uint256_add(arrayLoc256, length)
        assert carry = 0
        let (loc: felt) = narrow_safe(res)
        dict_write{dict_ptr=warp_memory}(loc, value)
    else :
        let (newCapacity, mulCarry) = uint256_mul(capacity, Uint256(2, 0))
        assert mulCarry = Uint256(0, 0)
        let (newArrayLoc) = wm_alloc(newCapacity)

        let (len) = narrow_safe(length)
        wm_copy(arrayLoc, newArrayLoc, len)

        dict_write{dict_ptr=warp_memory}(bytesLoc + 2, newCapacity.low)
        dict_write{dict_ptr=warp_memory}(bytesLoc + 3, newCapacity.high)
        dict_write{dict_ptr=warp_memory}(bytesLoc + 4, newArrayLoc)

        let (arrayLoc256) = felt_to_uint256(newArrayLoc)
        let (res: Uint256, carry: felt) = uint256_add(arrayLoc256, length)
        assert carry = 0
        let (loc: felt) = narrow_safe(res)

        dict_write{dict_ptr=warp_memory}(loc, value)
    end
    return (newLength,)
end

func wm_bytes_pop{range_check_ptr, warp_memory: DictAccess*}(bytesLoc: felt) -> (
    value: felt, len: Uint256
) :
    alloc_locals
    let (length) = wm_read_256(bytesLoc)
    if length.low + length.high == 0 :
        assert 1 = 0
    end

    let (newLength) = uint256_sub(length, Uint256(1, 0))

    let (arrayLoc) = wm_read_felt(bytesLoc + 4)
    let (arrayLoc256) = felt_to_uint256(arrayLoc)
    let (res: Uint256, carry: felt) = uint256_add(arrayLoc256, newLength)
    assert carry = 0
    let (loc: felt) = narrow_safe(res)

    let (value) = dict_read{dict_ptr=warp_memory}(loc)

    dict_write{dict_ptr=warp_memory}(bytesLoc, newLength.low)
    dict_write{dict_ptr=warp_memory}(bytesLoc + 1, newLength.high)

    return (value, newLength)
end

func wm_bytes_index{range_check_ptr, warp_memory: DictAccess*}(bytesLoc: felt, index: Uint256) -> (
    res: felt
) :
    alloc_locals

    let (arrayLoc) = wm_read_felt(bytesLoc + 4)

    let (length: Uint256) = wm_read_256(bytesLoc)
    let (inRange) = uint256_lt(index, length)
    assert inRange = 1

    let (arrayLoc256) = felt_to_uint256(arrayLoc)
    let (res256: Uint256, carry) = uint256_add(arrayLoc256, index)
    assert carry = 0
    let (res) = narrow_safe(res256)

    return (res,)
end

func wm_bytes_length{warp_memory: DictAccess*}(bytesLoc: felt) -> (len: Uint256) :
    let (res: Uint256) = wm_read_256(bytesLoc)
    return (res,)
end

func wm_bytes_to_fixed32{range_check_ptr, warp_memory: DictAccess*}(bytesLoc: felt) -> (
    res: Uint256
) :
    alloc_locals
    let (dataLength) = wm_read_256(bytesLoc)
    if dataLength.high == 0 :
        let (high) = wm_bytes_to_fixed_helper(bytesLoc + 2, 16, dataLength.low, 0)
        let short = is_le(dataLength.low, 16)
        if short == 0 :
            let (low) = wm_bytes_to_fixed_helper(bytesLoc + 18, 16, dataLength.low - 16, 0)
            return (Uint256(low, high),)
        else :
            return (Uint256(0, high),)
        end
    else :
        let (high) = wm_bytes_to_fixed_helper(bytesLoc + 2, 16, 16, 0)
        let (low) = wm_bytes_to_fixed_helper(bytesLoc + 18, 16, 16, 0)
        return (Uint256(low, high),)
    end
end

func wm_bytes_to_fixed{warp_memory: DictAccess*}(bytesLoc: felt, width: felt) -> (res: felt) :
    alloc_locals
    let (dataLength) = wm_read_256(bytesLoc)
    if dataLength.high == 0 :
        return wm_bytes_to_fixed_helper(bytesLoc + 2, width, dataLength.low, 0)
    else :
        return wm_bytes_to_fixed_helper(bytesLoc + 2, width, width, 0)
    end
end


func index_struct(loc: felt, index: felt) -> (indexLoc: felt) :
    return (loc + index,)
end

func wm_read_id{range_check_ptr: felt, warp_memory: DictAccess*}(loc: felt, size: Uint256) -> (
    val: felt
) :
    let (id) = dict_read{dict_ptr=warp_memory}(loc)
    if id != 0 :
        return (id,)
    end
    let (id) = wm_alloc(size)
    dict_write{dict_ptr=warp_memory}(loc, id)
    return (id,)
end

func wm_alloc{range_check_ptr, warp_memory: DictAccess*}(space: Uint256) -> (start: felt) :
    alloc_locals
    let (freeCell) = dict_read{dict_ptr=warp_memory}(0)

    let (freeCell256) = felt_to_uint256(freeCell)
    let (newFreeCell256: Uint256, carry) = uint256_add(freeCell256, space)
    assert carry = 0
    let (newFreeCell) = narrow_safe(newFreeCell256)
    dict_write{dict_ptr=warp_memory}(0, newFreeCell)
    return (freeCell,)
end

func wm_copy{warp_memory: DictAccess*}(src: felt, dst: felt, length: felt) :
    alloc_locals
    if length == 0 :
        return ()
    end

    let (srcVal) = dict_read{dict_ptr=warp_memory}(src)
    dict_write{dict_ptr=warp_memory}(dst, srcVal)

    wm_copy(src + 1, dst + 1, length - 1)
    return ()
end

func wm_to_felt_array{range_check_ptr, warp_memory: DictAccess*}(loc: felt) -> (
    length: felt, output: felt*
) :
    alloc_locals
    let (output: felt*) = alloc()

    let (lengthUint256: Uint256) = wm_read_256(loc)
    let (length_felt: felt) = narrow_safe(lengthUint256)

    wm_to_felt_array_helper(loc + 2, 0, length_felt, output)

    return (length_felt, output)
end

func wm_to_felt_array_helper{range_check_ptr, warp_memory: DictAccess*}(
    loc: felt, index: felt, length: felt, output: felt*
) :
    alloc_locals
    if index == length :
        return ()
    end

    let (value: felt) = dict_read{dict_ptr=warp_memory}(loc)
    assert output[index] = value

    return wm_to_felt_array_helper(loc + 1, index + 1, length, output)
end

func wm_bytes_to_fixed_helper{warp_memory: DictAccess*}(
    bytesDataLoc: felt, targetWidth: felt, dataLength: felt, acc: felt
) -> (res: felt) :
    alloc_locals
    if targetWidth == 0 :
        return (acc,)
    end
    if dataLength == 0 :
        return wm_bytes_to_fixed_helper(
            bytesDataLoc + 1, targetWidth - 1, dataLength - 1, 256 * acc
        )
    else :
        let (byte) = wm_read_felt(bytesDataLoc)
        return wm_bytes_to_fixed_helper(
            bytesDataLoc + 1, targetWidth - 1, dataLength - 1, 256 * acc + byte
        )
    end
end
