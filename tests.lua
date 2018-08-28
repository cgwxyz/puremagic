local puremagic = require('puremagic')


local successful = 0
local run = 0


function test_file(name, mimetype)
    local path = './test_files/' .. name
    local inspected_mimetype = puremagic.via_path(path)
    if inspected_mimetype ~= mimetype then
        print(path .. ' detected as ' .. inspected_mimetype .. ' instead of ' .. mimetype)
    else
        print(path .. ' detected as ' .. inspected_mimetype)
        successful = successful + 1
    end
    run = run + 1
end

test_file('test.gif',         'image/gif')
test_file('test.jpg',         'image/jpeg')
test_file('test.webp',        'image/webp')
test_file('test.png',         'image/png')

print()
print(successful .. ' of ' .. run .. ' successful')
if successful ~= run then
    print((run - successful) .. ' errors')
end
