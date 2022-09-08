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
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from warplib.maths.eq import warp_eq, warp_eq256
from warplib.maths.neq import warp_neq
from warplib.maths.sub import warp_sub256
from starkware.cairo.common.dict_access import DictAccess
from warplib.maths.add import warp_add256
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

func WS1_READ_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
) -> (val : felt):
    alloc_locals
    let (read0) = WARP_STORAGE.read(loc)
    return (read0)
end

func WS2_READ_Uint256{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt
) -> (val : Uint256):
    alloc_locals
    let (read0) = WARP_STORAGE.read(loc)
    let (read1) = WARP_STORAGE.read(loc + 1)
    return (Uint256(low=read0, high=read1))
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

func WS_WRITE1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    loc : felt, value : Uint256
) -> (res : Uint256):
    WARP_STORAGE.write(loc, value.low)
    WARP_STORAGE.write(loc + 1, value.high)
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
func WS0_INDEX_Uint256_to_felt{
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

@storage_var
func WARP_MAPPING1(name : felt, index : felt) -> (resLoc : felt):
end
func WS1_INDEX_felt_to_Uint256{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(name : felt, index : felt) -> (res : felt):
    alloc_locals
    let (existing) = WARP_MAPPING1.read(name, index)
    if existing == 0:
        let (used) = WARP_USED_STORAGE.read()
        WARP_USED_STORAGE.write(used + 2)
        WARP_MAPPING1.write(name, index, used)
        return (used)
    else:
        return (existing)
    end
end

@storage_var
func WARP_MAPPING2(name : felt, index : Uint256) -> (resLoc : felt):
end
func WS2_INDEX_Uint256_to_warp_id{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
}(name : felt, index : Uint256) -> (res : felt):
    alloc_locals
    let (existing) = WARP_MAPPING2.read(name, index)
    if existing == 0:
        let (used) = WARP_USED_STORAGE.read()
        WARP_USED_STORAGE.write(used + 1)
        WARP_MAPPING2.write(name, index, used)
        return (used)
    else:
        return (existing)
    end
end

# Contract Def NethermindSBT

@event
func Recovered_fff3b384(
    __warp_usrid4__oldSoul : felt, __warp_usrid5__newSoul : felt, __warp_usrid6__tokenId : Uint256
):
end

@event
func Revoked_713b9088(__warp_usrid2__soul : felt, __warp_usrid3__tokenId : Uint256):
end

@event
func Issued_a59f12e3(__warp_usrid0__soul : felt, __warp_usrid1__tokenId : Uint256):
end

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

namespace NethermindSBT:
    # Dynamic variables - Arrays and Maps

    const __warp_usrid3__name = 1

    const __warp_usrid4_uri = 2

    const __warp_usrid5_owner = 3

    const __warp_usrid6_token = 4

    # Static variables

    const __warp_usrid0_issuer = 0

    const __warp_usrid1_tokenIdCounter = 1

    const __warp_usrid2__totalSupply = 3

    func __warp_onlyIssuer_9{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_parameter6 : felt, __warp_parameter7 : felt, __warp_parameter8 : Uint256) -> ():
        alloc_locals

        let (__warp_se_0) = get_caller_address()

        let (__warp_se_1) = WS1_READ_felt(__warp_usrid0_issuer)

        let (__warp_se_2) = warp_eq(__warp_se_0, __warp_se_1)

        assert __warp_se_2 = 1

        __warp_original_function_recover_1ec82cb8(
            __warp_parameter6, __warp_parameter7, __warp_parameter8
        )

        return ()
    end

    func __warp_original_function_recover_1ec82cb8{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(
        __warp_usrid14__oldSoul : felt,
        __warp_usrid15__newSoul : felt,
        __warp_usrid16__tokenId : Uint256,
    ) -> ():
        alloc_locals

        let (__warp_se_3) = WS0_INDEX_Uint256_to_felt(__warp_usrid5_owner, __warp_usrid16__tokenId)

        let (__warp_se_4) = WS1_READ_felt(__warp_se_3)

        let (__warp_se_5) = warp_eq(__warp_usrid14__oldSoul, __warp_se_4)

        with_attr error_message("current owner is not equal to _oldSoul"):
            assert __warp_se_5 = 1
        end

        let (__warp_se_6) = WS1_INDEX_felt_to_Uint256(__warp_usrid6_token, __warp_usrid14__oldSoul)

        let (__warp_se_7) = WS2_READ_Uint256(__warp_se_6)

        let (__warp_se_8) = warp_eq256(__warp_usrid16__tokenId, __warp_se_7)

        with_attr error_message("_oldSoul is not the owner of _tokenId"):
            assert __warp_se_8 = 1
        end

        let (__warp_se_9) = warp_neq(__warp_usrid15__newSoul, 0)

        with_attr error_message("_newSoul is equal to 0"):
            assert __warp_se_9 = 1
        end

        let (__warp_se_10) = WS0_INDEX_Uint256_to_felt(__warp_usrid5_owner, __warp_usrid16__tokenId)

        WS_WRITE0(__warp_se_10, __warp_usrid15__newSoul)

        let (__warp_se_11) = WS1_INDEX_felt_to_Uint256(__warp_usrid6_token, __warp_usrid14__oldSoul)

        WS_WRITE1(__warp_se_11, Uint256(low=0, high=0))

        let (__warp_se_12) = WS1_INDEX_felt_to_Uint256(__warp_usrid6_token, __warp_usrid15__newSoul)

        WS_WRITE1(__warp_se_12, __warp_usrid16__tokenId)

        Recovered_fff3b384.emit(
            __warp_usrid14__oldSoul, __warp_usrid15__newSoul, __warp_usrid16__tokenId
        )

        return ()
    end

    func __warp_onlyIssuer_5{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
    }(__warp_parameter3 : felt, __warp_parameter4 : Uint256) -> ():
        alloc_locals

        let (__warp_se_13) = get_caller_address()

        let (__warp_se_14) = WS1_READ_felt(__warp_usrid0_issuer)

        let (__warp_se_15) = warp_eq(__warp_se_13, __warp_se_14)

        assert __warp_se_15 = 1

        __warp_original_function_revoke_eac449d9(__warp_parameter3, __warp_parameter4)

        return ()
    end

    func __warp_original_function_revoke_eac449d9{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
    }(__warp_usrid12__soul : felt, __warp_usrid13__tokenId : Uint256) -> ():
        alloc_locals

        let (__warp_se_16) = WS2_INDEX_Uint256_to_warp_id(
            __warp_usrid4_uri, __warp_usrid13__tokenId
        )

        let (__warp_se_17) = WS0_READ_warp_id(__warp_se_16)

        WS0_DYNAMIC_ARRAY_DELETE(__warp_se_17)

        let (__warp_se_18) = WS0_INDEX_Uint256_to_felt(__warp_usrid5_owner, __warp_usrid13__tokenId)

        WS_WRITE0(__warp_se_18, 0)

        let (__warp_se_19) = WS1_INDEX_felt_to_Uint256(__warp_usrid6_token, __warp_usrid12__soul)

        WS_WRITE1(__warp_se_19, Uint256(low=0, high=0))

        let (__warp_se_20) = WS2_READ_Uint256(__warp_usrid2__totalSupply)

        let (__warp_se_21) = warp_sub256(__warp_se_20, Uint256(low=1, high=0))

        WS_WRITE1(__warp_usrid2__totalSupply, __warp_se_21)

        Revoked_713b9088.emit(__warp_usrid12__soul, __warp_usrid13__tokenId)

        return ()
    end

    func __warp_onlyIssuer_2{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        warp_memory : DictAccess*,
    }(__warp_parameter0 : felt, __warp_parameter1 : felt) -> ():
        alloc_locals

        let (__warp_se_22) = get_caller_address()

        let (__warp_se_23) = WS1_READ_felt(__warp_usrid0_issuer)

        let (__warp_se_24) = warp_eq(__warp_se_22, __warp_se_23)

        assert __warp_se_24 = 1

        __warp_original_function_issue_04b444d9(__warp_parameter0, __warp_parameter1)

        return ()
    end

    func __warp_original_function_issue_04b444d9{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        warp_memory : DictAccess*,
    }(__warp_usrid10__soul : felt, __warp_usrid11__uri : felt) -> ():
        alloc_locals

        let (__warp_se_25) = warp_neq(__warp_usrid10__soul, 0)

        assert __warp_se_25 = 1

        let (__warp_se_26) = WS2_READ_Uint256(__warp_usrid1_tokenIdCounter)

        let (__warp_se_27) = WS2_INDEX_Uint256_to_warp_id(__warp_usrid4_uri, __warp_se_26)

        let (__warp_se_28) = WS0_READ_warp_id(__warp_se_27)

        wm_to_storage0(__warp_se_28, __warp_usrid11__uri)

        let (__warp_se_29) = WS2_READ_Uint256(__warp_usrid1_tokenIdCounter)

        let (__warp_se_30) = WS0_INDEX_Uint256_to_felt(__warp_usrid5_owner, __warp_se_29)

        WS_WRITE0(__warp_se_30, __warp_usrid10__soul)

        let (__warp_se_31) = WS1_INDEX_felt_to_Uint256(__warp_usrid6_token, __warp_usrid10__soul)

        let (__warp_se_32) = WS2_READ_Uint256(__warp_usrid1_tokenIdCounter)

        WS_WRITE1(__warp_se_31, __warp_se_32)

        let (__warp_se_33) = WS2_READ_Uint256(__warp_usrid1_tokenIdCounter)

        Issued_a59f12e3.emit(__warp_usrid10__soul, __warp_se_33)

        let (__warp_se_34) = WS2_READ_Uint256(__warp_usrid1_tokenIdCounter)

        let (__warp_se_35) = warp_add256(__warp_se_34, Uint256(low=1, high=0))

        WS_WRITE1(__warp_usrid1_tokenIdCounter, __warp_se_35)

        let (__warp_se_36) = WS2_READ_Uint256(__warp_usrid2__totalSupply)

        let (__warp_se_37) = warp_add256(__warp_se_36, Uint256(low=1, high=0))

        WS_WRITE1(__warp_usrid2__totalSupply, __warp_se_37)

        return ()
    end

    func __warp_constructor_0{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        warp_memory : DictAccess*,
    }(__warp_usrid7__issuer : felt, __warp_usrid8_name_ : felt) -> ():
        alloc_locals

        WS_WRITE0(__warp_usrid0_issuer, __warp_usrid7__issuer)

        wm_to_storage0(__warp_usrid3__name, __warp_usrid8_name_)

        return ()
    end

    @view
    func name_06fdde03{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        ) -> (__warp_usrid9__len : felt, __warp_usrid9_ : felt*):
        alloc_locals

        let (__warp_se_38) = ws_dynamic_array_to_calldata0(__warp_usrid3__name)

        return (__warp_se_38.len, __warp_se_38.ptr)
    end

    @external
    func issue_04b444d9{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        __warp_usrid10__soul : felt, __warp_usrid11__uri_len : felt, __warp_usrid11__uri : felt*
    ) -> ():
        alloc_locals
        let (local warp_memory : DictAccess*) = default_dict_new(0)
        local warp_memory_start : DictAccess* = warp_memory
        dict_write{dict_ptr=warp_memory}(0, 1)
        with warp_memory:
            extern_input_check0(__warp_usrid11__uri_len, __warp_usrid11__uri)

            warp_external_input_check_address(__warp_usrid10__soul)

            local __warp_usrid11__uri_dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid11__uri_len, __warp_usrid11__uri)

            let (__warp_usrid11__uri_mem) = cd_to_memory0(__warp_usrid11__uri_dstruct)

            __warp_onlyIssuer_2(__warp_usrid10__soul, __warp_usrid11__uri_mem)

            default_dict_finalize(warp_memory_start, warp_memory, 0)

            return ()
        end
    end

    @external
    func revoke_eac449d9{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr : felt,
        bitwise_ptr : BitwiseBuiltin*,
    }(__warp_usrid12__soul : felt, __warp_usrid13__tokenId : Uint256) -> ():
        alloc_locals

        warp_external_input_check_int256(__warp_usrid13__tokenId)

        warp_external_input_check_address(__warp_usrid12__soul)

        __warp_onlyIssuer_5(__warp_usrid12__soul, __warp_usrid13__tokenId)

        return ()
    end

    @external
    func recover_1ec82cb8{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        __warp_usrid14__oldSoul : felt,
        __warp_usrid15__newSoul : felt,
        __warp_usrid16__tokenId : Uint256,
    ) -> ():
        alloc_locals

        warp_external_input_check_int256(__warp_usrid16__tokenId)

        warp_external_input_check_address(__warp_usrid15__newSoul)

        warp_external_input_check_address(__warp_usrid14__oldSoul)

        __warp_onlyIssuer_9(
            __warp_usrid14__oldSoul, __warp_usrid15__newSoul, __warp_usrid16__tokenId
        )

        return ()
    end

    @view
    func ownerOf_6352211e{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        __warp_usrid17__tokenId : Uint256
    ) -> (__warp_usrid18_ : felt):
        alloc_locals

        warp_external_input_check_int256(__warp_usrid17__tokenId)

        let (__warp_se_39) = WS0_INDEX_Uint256_to_felt(__warp_usrid5_owner, __warp_usrid17__tokenId)

        let (__warp_se_40) = WS1_READ_felt(__warp_se_39)

        return (__warp_se_40)
    end

    @view
    func tokenOfOwner_294cdf0d{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid19__soul : felt) -> (__warp_usrid20_ : Uint256):
        alloc_locals

        warp_external_input_check_address(__warp_usrid19__soul)

        let (__warp_se_41) = WS1_INDEX_felt_to_Uint256(__warp_usrid6_token, __warp_usrid19__soul)

        let (__warp_se_42) = WS2_READ_Uint256(__warp_se_41)

        return (__warp_se_42)
    end

    @view
    func totalSupply_18160ddd{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }() -> (__warp_usrid21_ : Uint256):
        alloc_locals

        let (__warp_se_43) = WS2_READ_Uint256(__warp_usrid2__totalSupply)

        return (__warp_se_43)
    end

    @view
    func tokenURI_c87b56dd{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt
    }(__warp_usrid22__tokenId : Uint256) -> (__warp_usrid23__len : felt, __warp_usrid23_ : felt*):
        alloc_locals

        warp_external_input_check_int256(__warp_usrid22__tokenId)

        let (__warp_se_44) = WS2_INDEX_Uint256_to_warp_id(
            __warp_usrid4_uri, __warp_usrid22__tokenId
        )

        let (__warp_se_45) = WS0_READ_warp_id(__warp_se_44)

        let (__warp_se_46) = ws_dynamic_array_to_calldata0(__warp_se_45)

        return (__warp_se_46.len, __warp_se_46.ptr)
    end

    @constructor
    func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
        __warp_usrid7__issuer : felt, __warp_usrid8_name__len : felt, __warp_usrid8_name_ : felt*
    ):
        alloc_locals
        WARP_USED_STORAGE.write(9)
        WARP_NAMEGEN.write(4)
        let (local warp_memory : DictAccess*) = default_dict_new(0)
        local warp_memory_start : DictAccess* = warp_memory
        dict_write{dict_ptr=warp_memory}(0, 1)
        with warp_memory:
            extern_input_check0(__warp_usrid8_name__len, __warp_usrid8_name_)

            warp_external_input_check_address(__warp_usrid7__issuer)

            local __warp_usrid8_name__dstruct : cd_dynarray_felt = cd_dynarray_felt(__warp_usrid8_name__len, __warp_usrid8_name_)

            let (__warp_usrid8_name__mem) = cd_to_memory0(__warp_usrid8_name__dstruct)

            __warp_constructor_0(__warp_usrid7__issuer, __warp_usrid8_name__mem)

            default_dict_finalize(warp_memory_start, warp_memory, 0)

            return ()
        end
    end
end

# Original soldity abi: ["constructor(address,string)","","name()","issue(address,string)","revoke(address,uint256)","recover(address,address,uint256)","ownerOf(uint256)","tokenOfOwner(address)","totalSupply()","tokenURI(uint256)","constructor()"]
