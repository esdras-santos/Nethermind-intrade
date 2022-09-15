%lang starknet

from starkware.cairo.common.dict import dict_read, dict_write
from starkware.cairo.common.uint256 import uint256_sub, uint256_lt, Uint256, uint256_eq, uint256_add
from warplib.memory import wm_dyn_array_length, wm_new
from warplib.maths.utils import narrow_safe, felt_to_uint256
from warplib.maths.int_conversions import warp_uint256
from starkware.cairo.common.alloc import alloc
from warplib.maths.external_input_check_address import warp_external_input_check_address
from warplib.maths.external_input_check_ints import (
    warp_external_input_check_int8,
    warp_external_input_check_int256,
)
from starkware.cairo.common.cairo_builtins import HashBuiltin
from warplib.maths.add import warp_add256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize

struct cd_dynarray_felt:
    member len : felt
    member ptr : felt*
end

func wm_to_storage0_elem{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    warp_memory : DictAccess*,
}(storage_name : felt, mem_loc : felt, length : Uint256) -> ():
    alloc_locals
    if length.low == 0:
        if length.high == 0:
            return ()
        end
    end
    let (index) = uint256_sub(length, Uint256(1, 0))
    let (storage_loc) = WARP_DARRAY0_felt.read(storage_name, index)
    let mem_loc = mem_loc - 1
    if storage_loc == 0:
        let (storage_loc) = WARP_USED_STORAGE.read()
        WARP_USED_STORAGE.write(storage_loc + 1)
        WARP_DARRAY0_felt.write(storage_name, index, storage_loc)
        let (copy) = dict_read{dict_ptr=warp_memory}(mem_loc)
        WARP_STORAGE.write(storage_loc, copy)
        return wm_to_storage0_elem(storage_name, mem_loc, index)
    else:
        let (copy) = dict_read{dict_ptr=warp_memory}(mem_loc)
        WARP_STORAGE.write(storage_loc, copy)
        return wm_to_storage0_elem(storage_name, mem_loc, index)
    end
end
func wm_to_storage0{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    warp_memory : DictAccess*,
}(loc : felt, mem_loc : felt) -> (loc : felt):
    alloc_locals
    let (length) = WARP_DARRAY0_felt_LENGTH.read(loc)
    let (mem_length) = wm_dyn_array_length(mem_loc)
    WARP_DARRAY0_felt_LENGTH.write(loc, mem_length)
    let (narrowedLength) = narrow_safe(mem_length)
    wm_to_storage0_elem(loc, mem_loc + 2 + 1 * narrowedLength, mem_length)
    let (lesser) = uint256_lt(mem_length, length)
    if lesser == 1:
        WS0_DYNAMIC_ARRAY_DELETE_elem(loc, mem_length, length)
        return (loc)
    else:
        return (loc)
    end
end

func WS0_DYNAMIC_ARRAY_DELETE_elem{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(loc : felt, index : Uint256, length : Uint256):
    alloc_locals
    let (stop) = uint256_eq(index, length)
    if stop == 1:
        return ()
    end
    let (elem_loc) = WARP_DARRAY0_felt.read(loc, index)
    WS1_DELETE(elem_loc)
    let (next_index, _) = uint256_add(index, Uint256(0x1, 0x0))
    return WS0_DYNAMIC_ARRAY_DELETE_elem(loc, next_index, length)
end
func WS0_DYNAMIC_ARRAY_DELETE{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(loc : felt):
    alloc_locals
    let (length) = WARP_DARRAY0_felt_LENGTH.read(loc)
    WARP_DARRAY0_felt_LENGTH.write(loc, Uint256(0x0, 0x0))
    return WS0_DYNAMIC_ARRAY_DELETE_elem(loc, Uint256(0x0, 0x0), length)
end

func WS1_DELETE{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
):
    WARP_STORAGE.write(loc, 0)
    return ()
end

func WS0_READ_warp_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
) -> (val : felt):
    alloc_locals
    let (read0) = readId(loc)
    return (read0)
end

func WS1_READ_Uint256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
) -> (val : Uint256):
    alloc_locals
    let (read0) = WARP_STORAGE.read(loc)
    let (read1) = WARP_STORAGE.read(loc + 1)
    return (Uint256(low=read0, high=read1))
end

func WS2_READ_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
) -> (val : felt):
    alloc_locals
    let (read0) = WARP_STORAGE.read(loc)
    return (read0)
end

func ws_dynamic_array_to_calldata0_write{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(loc : felt, index : felt, len : felt, ptr : felt*) -> (ptr : felt*):
    alloc_locals
    if len == index:
        return (ptr)
    end
    let (index_uint256) = warp_uint256(index)
    let (elem_loc) = WARP_DARRAY0_felt.read(loc, index_uint256)
    let (elem) = WS2_READ_felt(elem_loc)
    assert ptr[index] = elem
    return ws_dynamic_array_to_calldata0_write(loc, index + 1, len, ptr)
end
func ws_dynamic_array_to_calldata0{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(loc : felt) -> (dyn_array_struct : cd_dynarray_felt):
    alloc_locals
    let (len_uint256) = WARP_DARRAY0_felt_LENGTH.read(loc)
    let len = len_uint256.low + len_uint256.high * 128
    let (ptr : felt*) = alloc()
    let (ptr : felt*) = ws_dynamic_array_to_calldata0_write(loc, 0, len, ptr)
    let dyn_array_struct = cd_dynarray_felt(len, ptr)
    return (dyn_array_struct)
end

func WS_WRITE0{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt, value : Uint256
) -> (res : Uint256):
    WARP_STORAGE.write(loc, value.low)
    WARP_STORAGE.write(loc + 1, value.high)
    return (value)
end

func WS_WRITE1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt, value : felt
) -> (res : felt):
    WARP_STORAGE.write(loc, value)
    return (value)
end

func extern_input_check0{range_check_ptr : felt}(len : felt, ptr : felt*) -> ():
    alloc_locals
    if len == 0:
        return ()
    end
    warp_external_input_check_int8(ptr[0])
    extern_input_check0(len=len - 1, ptr=ptr + 1)
    return ()
end

func cd_to_memory0_elem{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    warp_memory : DictAccess*,
}(calldata : felt*, mem_start : felt, length : felt):
    alloc_locals
    if length == 0:
        return ()
    end
    dict_write{dict_ptr=warp_memory}(mem_start, calldata[0])
    return cd_to_memory0_elem(calldata + 1, mem_start + 1, length - 1)
end
func cd_to_memory0{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    warp_memory : DictAccess*,
}(calldata : cd_dynarray_felt) -> (mem_loc : felt):
    alloc_locals
    let (len256) = felt_to_uint256(calldata.len)
    let (mem_start) = wm_new(len256, Uint256(0x1, 0x0))
    cd_to_memory0_elem(calldata.ptr, mem_start + 2, calldata.len)
    return (mem_start)
end

@storage_var
func WARP_DARRAY0_felt(name : felt, index : Uint256) -> (resLoc : felt):
end
@storage_var
func WARP_DARRAY0_felt_LENGTH(name : felt) -> (index : Uint256):
end

@storage_var
func WARP_MAPPING0(name : felt, index : Uint256) -> (resLoc : felt):
end
func WS0_INDEX_Uint256_to_warp_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(name : felt, index : Uint256) -> (res : felt):
    alloc_locals
    let (existing) = WARP_MAPPING0.read(name, index)
    if existing == 0:
        let (used) = WARP_USED_STORAGE.read()
        WARP_USED_STORAGE.write(used + 1)
        WARP_MAPPING0.write(name, index, used)
        return (used)
    else:
        return (existing)
    end
end

# Contract Def ERC721Collection

@storage_var
func WARP_STORAGE(index : felt) -> (val : felt):
end
@storage_var
func WARP_USED_STORAGE() -> (val : felt):
end
@storage_var
func WARP_NAMEGEN() -> (name : felt):
end
func readId{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
) -> (val : felt):
    alloc_locals
    let (id) = WARP_STORAGE.read(loc)
    if id == 0:
        let (id) = WARP_NAMEGEN.read()
        WARP_NAMEGEN.write(id + 1)
        WARP_STORAGE.write(loc, id + 1)
        return (id + 1)
    else:
        return (id)
    end
end

namespace ERC721Collection:
    # Dynamic variables - Arrays and Maps

    const __warp_usrid2_tokenUri = 1

    # Static variables

    const __warp_usrid0_tokenCounter = 0

    const __warp_usrid1_factory = 2

    func __warp_constructor_0{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid3_name : felt, __warp_usrid4_symbol : felt) -> ():
        alloc_locals

        WS_WRITE0(__warp_usrid0_tokenCounter, Uint256(low=0, high=0))

        return ()
    end

    @external
    func createCollectible_5b193d07{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(
        __warp_usrid5__intern : felt,
        __warp_usrid6__tokenURI_len : felt,
        __warp_usrid6__tokenURI : felt*,
    ) -> (__warp_usrid7_ : Uint256):
        alloc_locals

        extern_input_check0(__warp_usrid6__tokenURI_len, __warp_usrid6__tokenURI)

        warp_external_input_check_address(__warp_usrid5__intern)

        let (__warp_usrid8_newItemId) = WS1_READ_Uint256(__warp_usrid0_tokenCounter)

        let (__warp_se_0) = WS1_READ_Uint256(__warp_usrid0_tokenCounter)

        let (__warp_se_1) = warp_add256(__warp_se_0, Uint256(low=1, high=0))

        WS_WRITE0(__warp_usrid0_tokenCounter, __warp_se_1)

        let (__warp_se_2) = get_caller_address()

        WS_WRITE1(__warp_usrid1_factory, __warp_se_2)

        return (__warp_usrid8_newItemId)
    end

    @view
    func tokenURI_c87b56dd{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid11_tokenId : Uint256) -> (__warp_usrid12__len : felt, __warp_usrid12_ : felt*):
        alloc_locals

        warp_external_input_check_int256(__warp_usrid11_tokenId)

        let (__warp_se_3) = WS0_INDEX_Uint256_to_warp_id(
            __warp_usrid2_tokenUri, __warp_usrid11_tokenId
        )

        let (__warp_se_4) = WS0_READ_warp_id(__warp_se_3)

        let (__warp_se_5) = ws_dynamic_array_to_calldata0(__warp_se_4)

        return (__warp_se_5.len, __warp_se_5.ptr)
    end

    @view
    func factory_c45a0155{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        ) -> (__warp_usrid13_ : felt):
        alloc_locals

        let (__warp_se_6) = WS2_READ_felt(__warp_usrid1_factory)

        return (__warp_se_6)
    end

    @view
    func tokenUri_1675f455{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid14__i0 : Uint256) -> (__warp_usrid15__len : felt, __warp_usrid15_ : felt*):
        alloc_locals

        warp_external_input_check_int256(__warp_usrid14__i0)

        let (__warp_se_7) = WS0_INDEX_Uint256_to_warp_id(__warp_usrid2_tokenUri, __warp_usrid14__i0)

        let (__warp_se_8) = WS0_READ_warp_id(__warp_se_7)

        let (__warp_se_9) = ws_dynamic_array_to_calldata0(__warp_se_8)

        return (__warp_se_9.len, __warp_se_9.ptr)
    end

    @constructor
    func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        __warp_usrid3_name_len : felt,
        __warp_usrid3_name : felt*,
        __warp_usrid4_symbol_len : felt,
        __warp_usrid4_symbol : felt*,
    ):
        alloc_locals
        WARP_USED_STORAGE.write(4)
        WARP_NAMEGEN.write(1)
        let (local warp_memory : DictAccess*) = default_dict_new(0)
        local warp_memory_start : DictAccess* = warp_memory
        dict_write{dict_ptr=warp_memory}(0, 1)
        with warp_memory:
            extern_input_check0(__warp_usrid4_symbol_len, __warp_usrid4_symbol)

            extern_input_check0(__warp_usrid3_name_len, __warp_usrid3_name)

            local __warp_usrid4_symbol_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid4_symbol_len, __warp_usrid4_symbol)

            let (__warp_usrid4_symbol_mem) = cd_to_memory0(__warp_usrid4_symbol_dstruct)

            local __warp_usrid3_name_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid3_name_len, __warp_usrid3_name)

            let (__warp_usrid3_name_mem) = cd_to_memory0(__warp_usrid3_name_dstruct)

            __warp_constructor_0(__warp_usrid3_name_mem, __warp_usrid4_symbol_mem)

            default_dict_finalize(warp_memory_start, warp_memory, 0)

            return ()
        end
    end
end

# Original soldity abi: ["constructor(string,string)","","createCollectible(address,string)","tokenURI(uint256)","factory()","tokenUri(uint256)"]
