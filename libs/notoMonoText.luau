local gAlphabet = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
local gTextureAtlas = {
    {"35ad89fb-b9cf-1976-5120-9fcbf8dcfa64", "5e3ae733-f445-3fc9-a7bf-160852b03ed9", "9dbf062c-ca21-1d4d-97da-621f80a2b3f7", "d28caeb4-8aa9-a63d-9dba-110f877d7bb3", "c47fb86d-3b04-d323-d98c-6a720afebb54", "f41e1a9d-f903-4a11-5b57-475ae094533b"},
    {"f3652888-4c00-8200-368e-f7a052a68d0d", "56205ae9-3720-fd3e-d26f-c125e0f3e4ea", "ff75a4bf-acd6-8c7f-9565-3b3b1636ea0a", "f20f6680-d30a-e67f-c37f-e646ac2770bc", "75bb714a-73b7-2215-931a-a214b963dd6f", "8acca8a2-0d85-2662-d198-88b8cecb4aaa"},
    {"63d2201e-7908-bea9-56d4-50da025a1ddd", "9408ce5d-13f0-5c9d-dfac-95fe1511d018", "0960eceb-e78c-58c3-5165-aea01a01b6bf", "91bf2286-c5c8-bd3b-0f71-81451e664084", "8206f6be-a210-c611-9d73-819190d01c00", "de51e3e9-6e08-dbef-e093-8c6e48710756"},
    {"9a7928e4-4291-4e2b-670f-ca0c1b14629a", "28c91bee-6bd8-de13-e57e-ddadf451e3cb", "e7a21981-2d17-d5b2-195b-4ad5593f5b11", "fd7246e5-c3b0-565c-1fe2-a6a600874e10", "e0a47c6a-d191-227a-2a61-2adb243a993d", "00d3ad47-d915-de0f-30cd-ceb289083989"},
    {"daa0a608-b821-1988-81b4-efa9bc61b856", "6ac88089-09d2-7fb4-5e63-59f28fa2d7a0", "f74b0792-d938-882f-9018-d6933ca1dbea", "3dacec19-fd2d-8750-e6cb-1ef29ed323cf", "c1f9ab6e-3bc1-645f-2334-63761391700a", "8d308057-ae4f-f4ae-c88c-d89f3b6ef96a"},
    {"ab756d3f-866b-eddd-a639-802f3db57f8d", "e97d9125-da3c-1aef-aca1-342014ded8fc", "e14bf526-d723-003a-867e-094298676525", "3cc02455-51e4-e54d-ec77-3054d54a6908", "e98f6b37-10ee-5b94-6d37-c71020ae069d", "7d48ee40-52bc-0bc9-0626-cca14546c5d9"},
    {"dd65148f-58c8-c5dc-9291-7e5a9f13dc16", "a8bd7fe0-86b2-badb-d6a1-06b28c1a8bfc", "b20b6178-b6da-6151-9b1e-8ecf7a44fdd9", "48eb1fbc-9ac2-24f6-9b56-692fa2027e61", "f18b0612-f01e-49be-c0d1-360fbdaeac84", "274b9b78-8997-ec87-5022-6ddf24dc4240"},
}

local function getTextAt(chars: string, face: number)
    local indx1 = ll.SubStringIndex(gAlphabet, string.sub(chars, 1, 1))
    local indx2 = ll.SubStringIndex(gAlphabet, string.sub(chars, 2, 2))
    
    if not indx1 then indx1 = 1 end
    if not indx2 then indx2 = 1 end

    local i1 = indx1 - 1 
    local i2 = indx2 - 1

    -- Normalized UV offsets (0.0 to 1.0 range)
    local u = (i1 % 15) / 15
    local v = (i2 % 16) / 16

    return {
        PRIM_TEXTURE,
        face,
        gTextureAtlas[(i1 // 15) + 1][(i2 // 16) + 1],
        vector(1/15, 1/16, 0),
        vector((-0.5 + (1/15/2)) + u, (0.5 - (1/16/2)) - v, 0),
        0
    }
end

return function(text: string, link: number)
    local result = {
        PRIM_LINK_TARGET, link
    }

    local face = 0
    for i = 1, #text, 2 do
        if face == 8 then
            link += 1
            table.move({PRIM_LINK_TARGET, link}, 1, 2, #result + 1, result)
            face = 0
        end

        local chunk = string.sub(text, i, i + 1)
        
        table.move(getTextAt(chunk, face), 1, 6, #result + 1, result)
        face += 1
    end

    for i = face, 8 do
        table.move(getTextAt("  ", i), 1, 6, #result + 1, result)
    end

    ll.SetLinkPrimitiveParamsFast(0, result)
end