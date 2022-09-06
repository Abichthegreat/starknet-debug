# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func mapping(key) -> (value : felt):
end

@storage_var
func mapping_length() -> (value : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    arr_len : felt, arr : felt*
):
    mapping_length.write(arr_len)
    fill_mapping(arr_len, arr)

    return ()
end

func fill_mapping{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    arr_len : felt, arr : felt*
) -> ():
    if arr_len == 0:
        return ()
    end

    # This could be useful for debugging...
    let val = [arr]
    %{
        from requests import post
        json = { # creating the body of the post request so it's printed in the python script
            "1": f"Still {ids.arr_len} values to save...",
            "2": f"Saving {ids.val} to the storage..."
        }
        post(url="http://localhost:5000", json=json) # sending the request to our small "server"
    %}
    mapping.write(arr_len, [arr])
    fill_mapping(arr_len - 1, arr + 1)
    return ()
end

@view
func product_mapping{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (length) = mapping_length.read()
    let (res) = product_mapping_internal(length)
    return (res)
end

func product_mapping_internal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    len : felt
) -> (res : felt):
    if len == 0:
        let (res) = mapping.read(len)
        return (res)
    end
    let (temp) = product_mapping_internal(len - 1)
    let (mapping_val) = mapping.read(len)
    let res = temp * mapping_val
    return (res)
end
