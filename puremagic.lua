-- puremagic 1.0.1
-- Copyright (c) 2014 Will Bond <will@wbond.net>
-- Licensed under the MIT license.


function basename(path)
    local basename_match = path:match('[/\\]([^/\\]+)$')
    if basename_match then
        return basename_match, nil
    end

    return path, nil
end


function extension(path)
    path = path:lower()
    local tar_match = path:match('%.(tar%.[^.]+)$')
    if tar_match then
        return tar_match
    end
    if path:sub(#path - 11, #path) == '.numbers.zip' then
        return 'numbers.zip'
    end
    if path:sub(#path - 9, #path) == '.pages.zip' then
        return 'pages.zip'
    end
    if path:sub(#path - 7, #path) == '.key.zip' then
        return 'key.zip'
    end
    return path:match('%.([^.]+)$')
end


function in_table(value, list)
    for i=1, #list do
        if list[i] == value then
            return true
        end
    end
    return false
end


function string_to_bit_table(chars)
    local output = {}
    for char in chars:gmatch('.') do
        local num = string.byte(char)
        local bits = {0, 0, 0, 0, 0, 0, 0, 0}
        for bit=8, 1, -1 do
            if num > 0 then
                bits[bit] = math.fmod(num, 2)
                num = (num - bits[bit]) / 2
            end
        end
        table.insert(output, bits)
    end
    return output
end


function bit_table_to_string(bits)
    local output = {}
    for i = 1, #bits do
        local num = tonumber(table.concat(bits[i]), 2)
        table.insert(output, string.format('%c', num))
    end
    return table.concat(output)
end



function bitwise_and(a, b)
    local a_bytes = string_to_bit_table(a)
    local b_bytes = string_to_bit_table(b)

    local output = {}
    for i = 1, #a_bytes do
        local bits = {0, 0, 0, 0, 0, 0, 0, 0}
        for j = 1, 8 do
            if a_bytes[i][j] == 1 and b_bytes[i][j] == 1 then
                bits[j] = 1
            else
                bits[j] = 0
            end
        end
        table.insert(output, bits)
    end

    return bit_table_to_string(output)
end


-- Unpack a little endian byte string into an integer
function unpack_le(chars)
    local bit_table = string_to_bit_table(chars)
    -- Merge the bits into a string of 1s and 0s
    local result = {}
    for i=1, #bit_table do
        result[#chars + 1 - i] = table.concat(bit_table[i])
    end
    return tonumber(table.concat(result), 2)
end


-- Unpack a big endian byte string into an integer
function unpack_be(chars)
    local bit_table = string_to_bit_table(chars)
    -- Merge the bits into a string of 1s and 0s
    for i=1, #bit_table do
        bit_table[i] = table.concat(bit_table[i])
    end
    return tonumber(table.concat(bit_table), 2)
end


function num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end


function str2hex(str)
    local hex = ''
    while #str > 0 do
        local hb = num2hex(string.byte(str, 1, 1))
        if #hb < 2 then hb = '0' .. hb end
        hex = hex .. hb
        str = string.sub(str, 2)
    end
    return hex
end


function binary_tests(content, ext)
    local length = #content
    local _1_8   = content:sub(1, 8)
    local _1_7   = content:sub(1, 7)
    local _1_6   = content:sub(1, 6)
    local _1_5   = content:sub(1, 5)
    local _1_4   = content:sub(1, 4)
    local _1_3   = content:sub(1, 3)
    local _1_2   = content:sub(1, 2)
    local _9_12  = content:sub(9, 12)

    -- Images
    -- PNG https://tools.ietf.org/html/rfc2083#section-12.11
    if str2hex(_1_8) == '89504e470d0a1a0a' then
        return 'image/png'
    end

    if _1_6 == 'GIF87a' or _1_6 == 'GIF89a' then
        return 'image/gif'
    end

    if _1_4 == 'RIFF' and _9_12 == 'WEBP' then
        return 'image/webp'
    end

    local normal_jpeg    = length > 10 and in_table(content:sub(7, 10), {'JFIF', 'Exif'})
    local photoshop_jpeg = length > 24 and _1_4 == '\xFF\xD8\xFF\xED' and content:sub(21, 24) == '8BIM'
    if normal_jpeg or photoshop_jpeg then
        return 'image/jpeg'
    end
    

    return nil
end

local _M = {}


function _M.via_path(path, filename)
    local f, err = io.open(path, 'r')
    if not f then
        return nil, err
    end

    local content = f:read(64)
    f:close()

    if not filename then
        filename = basename(path)
    end

    return _M.via_content(content, filename)
end


function _M.via_content(content, filename)
    local ext = extension(filename)

    -- If there are no low ASCII chars and no easily distinguishable tokens,
    -- we need to detect by file extension

    local mimetype = nil

    mimetype = binary_tests(content, ext)

    if mimetype then
        return mimetype
    end

    return mimetype
end

return _M
