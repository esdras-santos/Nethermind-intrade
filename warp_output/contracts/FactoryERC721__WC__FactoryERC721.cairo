%lang starknet

from warplib.memory import wm_read_felt, wm_read_256, wm_new, wm_dyn_array_length, wm_index_dyn
from starkware.cairo.common.uint256 import uint256_sub, uint256_add, Uint256
from starkware.cairo.common.alloc import alloc
from warplib.maths.utils import narrow_safe, felt_to_uint256
from warplib.maths.int_conversions import warp_uint256
from warplib.maths.external_input_check_address import warp_external_input_check_address
from warplib.maths.external_input_check_ints import warp_external_input_check_int8
from starkware.cairo.common.dict import dict_write
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from warplib.maths.lt import warp_lt256
from warplib.maths.neq import warp_neq
from warplib.maths.add import warp_add256
from warplib.maths.sub import warp_sub256
from starkware.starknet.common.syscalls import get_caller_address, deploy
from warplib.maths.eq import warp_eq
from warplib.string_hash import wm_string_hash
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize

# @declare contracts/ERC721Collection__WC__ERC721Collection.cairo
const contracts_ERC721Collection_ERC721Collection_efe2212b13fef754 = 0

struct cd_dynarray_felt:
    member len : felt
    member ptr : felt*
end

func wm_to_calldata0{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    warp_memory : DictAccess*,
}(mem_loc : felt) -> (retData : cd_dynarray_felt):
    alloc_locals
    let (len_256) = wm_read_256(mem_loc)
    let (ptr : felt*) = alloc()
    let (len_felt) = narrow_safe(len_256)
    wm_to_calldata1(len_felt, ptr, mem_loc + 2)
    return (cd_dynarray_felt(len=len_felt, ptr=ptr))
end

func wm_to_calldata1{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    warp_memory : DictAccess*,
}(len : felt, ptr : felt*, mem_loc : felt) -> ():
    alloc_locals
    if len == 0:
        return ()
    end
    let (mem_read0) = wm_read_felt(mem_loc)
    assert ptr[0] = mem_read0
    wm_to_calldata1(len=len - 1, ptr=ptr + 1, mem_loc=mem_loc + 1)
    return ()
end

func WARP_DARRAY0_felt_PUSHV0{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    bitwise_ptr : BitwiseBuiltin*,
}(loc : felt, value : felt) -> ():
    alloc_locals
    let (len) = WARP_DARRAY0_felt_LENGTH.read(loc)
    let (newLen, carry) = uint256_add(len, Uint256(1, 0))
    assert carry = 0
    WARP_DARRAY0_felt_LENGTH.write(loc, newLen)
    let (existing) = WARP_DARRAY0_felt.read(loc, len)
    if (existing) == 0:
        let (used) = WARP_USED_STORAGE.read()
        WARP_USED_STORAGE.write(used + 1)
        WARP_DARRAY0_felt.write(loc, len, used)
        WS_WRITE0(used, value)
    else:
        WS_WRITE0(existing, value)
    end
    return ()
end

func WS0_READ_warp_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
) -> (val : felt):
    alloc_locals
    let (read0) = readId(loc)
    return (read0)
end

func WS1_READ_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
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
    let (elem) = WS1_READ_felt(elem_loc)
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
    warp_external_input_check_address(ptr[0])
    extern_input_check0(len=len - 1, ptr=ptr + 1)
    return ()
end

func extern_input_check1{range_check_ptr : felt}(len : felt, ptr : felt*) -> ():
    alloc_locals
    if len == 0:
        return ()
    end
    warp_external_input_check_int8(ptr[0])
    extern_input_check1(len=len - 1, ptr=ptr + 1)
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

func cd_to_memory1_elem{
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
    return cd_to_memory1_elem(calldata + 1, mem_start + 1, length - 1)
end
func cd_to_memory1{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr : felt,
    warp_memory : DictAccess*,
}(calldata : cd_dynarray_felt) -> (mem_loc : felt):
    alloc_locals
    let (len256) = felt_to_uint256(calldata.len)
    let (mem_start) = wm_new(len256, Uint256(0x1, 0x0))
    cd_to_memory1_elem(calldata.ptr, mem_start + 2, calldata.len)
    return (mem_start)
end

func encode_dynamic_array0(
    to_index : felt, to_array : felt*, from_index : felt, from_size : felt, from_array : felt*
) -> (total_copied : felt):
    alloc_locals
    if from_index == from_size:
        return (total_copied=to_index)
    end
    let current_element = from_array[from_index]
    assert to_array[to_index] = current_element
    let to_index = to_index + 1
    return encode_dynamic_array0(to_index, to_array, from_index + 1, from_size, from_array)
end

func encode_as_felt0(arg_0_dynamic : cd_dynarray_felt, arg_1_dynamic : cd_dynarray_felt) -> (
    calldata_array : cd_dynarray_felt
):
    alloc_locals
    let total_size : felt = 0
    let (decode_array : felt*) = alloc()
    assert decode_array[total_size] = arg_0_dynamic.len
    let total_size = total_size + 1
    let (total_size) = encode_dynamic_array0(
        total_size, decode_array, 0, arg_0_dynamic.len, arg_0_dynamic.ptr
    )
    assert decode_array[total_size] = arg_1_dynamic.len
    let total_size = total_size + 1
    let (total_size) = encode_dynamic_array0(
        total_size, decode_array, 0, arg_1_dynamic.len, arg_1_dynamic.ptr
    )
    let result = cd_dynarray_felt(total_size, decode_array)
    return (result)
end

@storage_var
func WARP_DARRAY0_felt(name : felt, index : Uint256) -> (resLoc : felt):
end
@storage_var
func WARP_DARRAY0_felt_LENGTH(name : felt) -> (index : Uint256):
end

@storage_var
func WARP_MAPPING0(name : felt, index : felt) -> (resLoc : felt):
end
func WS0_INDEX_felt_to_warp_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(name : felt, index : felt) -> (res : felt):
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

# Contract Def FactoryERC721

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

namespace FactoryERC721:
    # Dynamic variables - Arrays and Maps

    const __warp_usrid1__collectionByYear = 1

    # Static variables

    const __warp_usrid0_owner = 0

    func __warp_while0{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
        warp_memory : DictAccess*,
    }(
        __warp_usrid9_i : Uint256,
        __warp_usrid3__interns : felt,
        __warp_usrid8_collection : felt,
        __warp_usrid5__tokenURI : felt,
    ) -> (
        __warp_usrid9_i : Uint256,
        __warp_usrid3__interns : felt,
        __warp_usrid8_collection : felt,
        __warp_usrid5__tokenURI : felt,
    ):
        alloc_locals

        let (__warp_se_0) = wm_dyn_array_length(__warp_usrid3__interns)

        let (__warp_se_1) = warp_lt256(__warp_usrid9_i, __warp_se_0)

        if __warp_se_1 != 0:
            let (__warp_se_2) = wm_index_dyn(
                __warp_usrid3__interns, __warp_usrid9_i, Uint256(low=1, high=0)
            )

            let (__warp_se_3) = wm_read_felt(__warp_se_2)

            let (__warp_se_4) = warp_neq(__warp_se_3, 0)

            assert __warp_se_4 = 1

            let (__warp_se_5) = wm_index_dyn(
                __warp_usrid3__interns, __warp_usrid9_i, Uint256(low=1, high=0)
            )

            let (__warp_se_6) = wm_read_felt(__warp_se_5)

            let (__warp_se_7) = wm_to_calldata0(__warp_usrid5__tokenURI)

            ERC721Collection_warped_interface.createCollectible_5b193d07(
                __warp_usrid8_collection, __warp_se_6, __warp_se_7.len, __warp_se_7.ptr
            )

            let (__warp_se_8) = warp_add256(__warp_usrid9_i, Uint256(low=1, high=0))

            let __warp_se_9 = __warp_se_8

            let __warp_usrid9_i = __warp_se_9

            warp_sub256(__warp_se_9, Uint256(low=1, high=0))

            let (
                __warp_usrid9_i, __warp_td_0, __warp_usrid8_collection, __warp_td_1
            ) = __warp_while0_if_part1(
                __warp_usrid9_i,
                __warp_usrid3__interns,
                __warp_usrid8_collection,
                __warp_usrid5__tokenURI,
            )

            let __warp_usrid3__interns = __warp_td_0

            let __warp_usrid5__tokenURI = __warp_td_1

            return (
                __warp_usrid9_i,
                __warp_usrid3__interns,
                __warp_usrid8_collection,
                __warp_usrid5__tokenURI,
            )
        else:
            let __warp_usrid9_i = __warp_usrid9_i

            let __warp_usrid3__interns = __warp_usrid3__interns

            let __warp_usrid8_collection = __warp_usrid8_collection

            let __warp_usrid5__tokenURI = __warp_usrid5__tokenURI

            return (
                __warp_usrid9_i,
                __warp_usrid3__interns,
                __warp_usrid8_collection,
                __warp_usrid5__tokenURI,
            )
        end
    end

    func __warp_while0_if_part1{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
        warp_memory : DictAccess*,
    }(
        __warp_usrid9_i : Uint256,
        __warp_usrid3__interns : felt,
        __warp_usrid8_collection : felt,
        __warp_usrid5__tokenURI : felt,
    ) -> (
        __warp_usrid9_i : Uint256,
        __warp_usrid3__interns : felt,
        __warp_usrid8_collection : felt,
        __warp_usrid5__tokenURI : felt,
    ):
        alloc_locals

        let (__warp_usrid9_i, __warp_td_4, __warp_usrid8_collection, __warp_td_5) = __warp_while0(
            __warp_usrid9_i,
            __warp_usrid3__interns,
            __warp_usrid8_collection,
            __warp_usrid5__tokenURI,
        )

        let __warp_usrid3__interns = __warp_td_4

        let __warp_usrid5__tokenURI = __warp_td_5

        return (
            __warp_usrid9_i,
            __warp_usrid3__interns,
            __warp_usrid8_collection,
            __warp_usrid5__tokenURI,
        )
    end

    func __warp_onlyOwner_7{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_parameter6 : felt) -> ():
        alloc_locals

        let (__warp_se_10) = get_caller_address()

        let (__warp_se_11) = WS1_READ_felt(__warp_usrid0_owner)

        let (__warp_se_12) = warp_eq(__warp_se_10, __warp_se_11)

        assert __warp_se_12 = 1

        __warp_original_function_setOwner_13af4035(__warp_parameter6)

        return ()
    end

    func __warp_original_function_setOwner_13af4035{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid12__newOwner : felt) -> ():
        alloc_locals

        WS_WRITE0(__warp_usrid0_owner, __warp_usrid12__newOwner)

        return ()
    end

    func __warp_onlyOwner_5{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
        warp_memory : DictAccess*,
    }(
        __warp_parameter0 : felt,
        __warp_parameter1 : felt,
        __warp_parameter2 : felt,
        __warp_parameter3 : felt,
        __warp_parameter4 : felt,
    ) -> ():
        alloc_locals

        let (__warp_se_13) = get_caller_address()

        let (__warp_se_14) = WS1_READ_felt(__warp_usrid0_owner)

        let (__warp_se_15) = warp_eq(__warp_se_13, __warp_se_14)

        assert __warp_se_15 = 1

        __warp_original_function_dropCollection_c6778438(
            __warp_parameter0,
            __warp_parameter1,
            __warp_parameter2,
            __warp_parameter3,
            __warp_parameter4,
        )

        return ()
    end

    func __warp_original_function_dropCollection_c6778438{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
        warp_memory : DictAccess*,
    }(
        __warp_usrid3__interns : felt,
        __warp_usrid4__year : felt,
        __warp_usrid5__tokenURI : felt,
        __warp_usrid6__collectionName : felt,
        __warp_usrid7__collectionSymbol : felt,
    ) -> ():
        alloc_locals

        let (__warp_se_16) = wm_string_hash(__warp_usrid4__year)

        let (__warp_se_17) = WS0_INDEX_felt_to_warp_id(
            __warp_usrid1__collectionByYear, __warp_se_16
        )

        let (__warp_se_18) = WS0_READ_warp_id(__warp_se_17)

        let (__warp_se_19) = WARP_DARRAY0_felt_LENGTH.read(__warp_se_18)

        let (__warp_se_20) = warp_lt256(__warp_se_19, Uint256(low=13, high=0))

        with_attr error_message("can't mint more collection than 13"):
            assert __warp_se_20 = 1
        end

        let (__warp_se_21) = wm_to_calldata0(__warp_usrid6__collectionName)

        let (__warp_se_22) = wm_to_calldata0(__warp_usrid7__collectionSymbol)

        let (__warp_se_23) = encode_as_felt0(__warp_se_21, __warp_se_22)

        let (__warp_usrid8_collection) = deploy(
            contracts_ERC721Collection_ERC721Collection_efe2212b13fef754,
            0,
            __warp_se_23.len,
            __warp_se_23.ptr,
            0,
        )

        let __warp_usrid9_i = Uint256(low=0, high=0)

        let (__warp_tv_0, __warp_td_6, __warp_tv_2, __warp_td_7) = __warp_while0(
            __warp_usrid9_i,
            __warp_usrid3__interns,
            __warp_usrid8_collection,
            __warp_usrid5__tokenURI,
        )

        let __warp_tv_1 = __warp_td_6

        let __warp_tv_3 = __warp_td_7

        let __warp_usrid5__tokenURI = __warp_tv_3

        let __warp_usrid8_collection = __warp_tv_2

        let __warp_usrid3__interns = __warp_tv_1

        let __warp_usrid9_i = __warp_tv_0

        let (__warp_se_24) = wm_string_hash(__warp_usrid4__year)

        let (__warp_se_25) = WS0_INDEX_felt_to_warp_id(
            __warp_usrid1__collectionByYear, __warp_se_24
        )

        let (__warp_se_26) = WS0_READ_warp_id(__warp_se_25)

        WARP_DARRAY0_felt_PUSHV0(__warp_se_26, __warp_usrid8_collection)

        return ()
    end

    func __warp_constructor_0{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid2__owner : felt) -> ():
        alloc_locals

        WS_WRITE0(__warp_usrid0_owner, __warp_usrid2__owner)

        return ()
    end

    @external
    func dropCollection_c6778438{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
    }(
        __warp_usrid3__interns_len : felt,
        __warp_usrid3__interns : felt*,
        __warp_usrid4__year_len : felt,
        __warp_usrid4__year : felt*,
        __warp_usrid5__tokenURI_len : felt,
        __warp_usrid5__tokenURI : felt*,
        __warp_usrid6__collectionName_len : felt,
        __warp_usrid6__collectionName : felt*,
        __warp_usrid7__collectionSymbol_len : felt,
        __warp_usrid7__collectionSymbol : felt*,
    ) -> ():
        alloc_locals
        let (local warp_memory : DictAccess*) = default_dict_new(0)
        local warp_memory_start : DictAccess* = warp_memory
        dict_write{dict_ptr=warp_memory}(0, 1)
        with warp_memory:
            extern_input_check1(
                __warp_usrid7__collectionSymbol_len, __warp_usrid7__collectionSymbol
            )

            extern_input_check1(__warp_usrid6__collectionName_len, __warp_usrid6__collectionName)

            extern_input_check1(__warp_usrid5__tokenURI_len, __warp_usrid5__tokenURI)

            extern_input_check1(__warp_usrid4__year_len, __warp_usrid4__year)

            extern_input_check0(__warp_usrid3__interns_len, __warp_usrid3__interns)

            local __warp_usrid7__collectionSymbol_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid7__collectionSymbol_len, __warp_usrid7__collectionSymbol)

            let (__warp_usrid7__collectionSymbol_mem) = cd_to_memory0(
                __warp_usrid7__collectionSymbol_dstruct
            )

            local __warp_usrid6__collectionName_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid6__collectionName_len, __warp_usrid6__collectionName)

            let (__warp_usrid6__collectionName_mem) = cd_to_memory0(
                __warp_usrid6__collectionName_dstruct
            )

            local __warp_usrid5__tokenURI_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid5__tokenURI_len, __warp_usrid5__tokenURI)

            let (__warp_usrid5__tokenURI_mem) = cd_to_memory0(__warp_usrid5__tokenURI_dstruct)

            local __warp_usrid4__year_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid4__year_len, __warp_usrid4__year)

            let (__warp_usrid4__year_mem) = cd_to_memory0(__warp_usrid4__year_dstruct)

            local __warp_usrid3__interns_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid3__interns_len, __warp_usrid3__interns)

            let (__warp_usrid3__interns_mem) = cd_to_memory1(__warp_usrid3__interns_dstruct)

            __warp_onlyOwner_5(
                __warp_usrid3__interns_mem,
                __warp_usrid4__year_mem,
                __warp_usrid5__tokenURI_mem,
                __warp_usrid6__collectionName_mem,
                __warp_usrid7__collectionSymbol_mem,
            )

            default_dict_finalize(warp_memory_start, warp_memory, 0)

            return ()
        end
    end

    @view
    func collectionByYear_f6f840a0{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid10__year_len : felt, __warp_usrid10__year : felt*) -> (
        __warp_usrid11__len : felt, __warp_usrid11_ : felt*
    ):
        alloc_locals
        let (local warp_memory : DictAccess*) = default_dict_new(0)
        local warp_memory_start : DictAccess* = warp_memory
        dict_write{dict_ptr=warp_memory}(0, 1)
        with warp_memory:
            extern_input_check1(__warp_usrid10__year_len, __warp_usrid10__year)

            local __warp_usrid10__year_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid10__year_len, __warp_usrid10__year)

            let (__warp_usrid10__year_mem) = cd_to_memory0(__warp_usrid10__year_dstruct)

            let (__warp_se_27) = wm_string_hash(__warp_usrid10__year_mem)

            let (__warp_se_28) = WS0_INDEX_felt_to_warp_id(
                __warp_usrid1__collectionByYear, __warp_se_27
            )

            let (__warp_se_29) = WS0_READ_warp_id(__warp_se_28)

            let (__warp_se_30) = ws_dynamic_array_to_calldata0(__warp_se_29)

            default_dict_finalize(warp_memory_start, warp_memory, 0)

            return (__warp_se_30.len, __warp_se_30.ptr)
        end
    end

    @external
    func setOwner_13af4035{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid12__newOwner : felt) -> ():
        alloc_locals

        warp_external_input_check_address(__warp_usrid12__newOwner)

        __warp_onlyOwner_7(__warp_usrid12__newOwner)

        return ()
    end

    @view
    func getOwner_893d20e8{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }() -> (__warp_usrid13_ : felt):
        alloc_locals

        let (__warp_se_31) = WS1_READ_felt(__warp_usrid0_owner)

        return (__warp_se_31)
    end

    @constructor
    func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        __warp_usrid2__owner : felt
    ):
        alloc_locals
        WARP_USED_STORAGE.write(2)
        WARP_NAMEGEN.write(1)

        warp_external_input_check_address(__warp_usrid2__owner)

        __warp_constructor_0(__warp_usrid2__owner)

        return ()
    end
end

# Contract Def ERC721Collection@interface

@contract_interface
namespace ERC721Collection_warped_interface:
    func createCollectible_5b193d07(
        __warp_usrid5__intern : felt,
        __warp_usrid6__tokenURI_len : felt,
        __warp_usrid6__tokenURI : felt*,
    ) -> (__warp_usrid7_ : Uint256):
    end

    func tokenURI_c87b56dd(__warp_usrid11_tokenId : Uint256) -> (
        __warp_usrid12__len : felt, __warp_usrid12_ : felt*
    ):
    end

    func factory_c45a0155() -> (__warp_usrid13_ : felt):
    end

    func tokenUri_1675f455(__warp_usrid14__i0 : Uint256) -> (
        __warp_usrid15__len : felt, __warp_usrid15_ : felt*
    ):
    end

    func constructor():
    end
end

# Original soldity abi: ["constructor(address)","","dropCollection(address[],string,string,string,string)","collectionByYear(string)","setOwner(address)","getOwner()"]
