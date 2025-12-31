local gAlphabet = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
local gTextureAtlas = {
    {"f9110828-bc55-a6ce-c315-94229222ff0f", "198ccef0-53c2-deaa-0179-45af96252de4", "cc807717-2e41-6d47-b9cc-49962b91c0b2", "23872acb-1e06-5369-e382-455cacc3fddb", "20426d13-756b-32a3-f624-cad02ca16a50", "b2768ed8-57ef-b914-1374-3a07a011710c"},
    {"adb1a5f3-0fdc-0ffc-92bf-74ca4d6c7157", "ff938d04-ee3b-dcf0-f93f-67ead9c89c51", "5697fa10-7e6a-33b7-59ef-cb0db2495ee6", "08aa6cf1-0a1a-275f-220d-a4332cfb9567", "33a0fab0-c603-34da-a89c-a8286d9e4a4d", "81d48732-26e9-30bd-7de2-441c41b57bfc"},
    {"10f2fd89-57b1-1202-9fee-65358c3f5025", "ccde33c4-19a0-7186-ddfe-217df353cd2b", "1ecb3991-dedb-4203-791c-fcbe7eea7551", "7c7d993b-e667-7a01-034f-371a9bbfedaf", "1c633979-1edd-59f6-7956-d86fa800453d", "bf0bc9f1-6b04-550b-4096-ea0ab81902f2"},
    {"59379b67-535f-17c4-239a-f54bb6115e55", "ab776b5c-07c5-c793-082f-5353a9ba0fea", "5594bebd-b6a6-0c38-cd7e-4783f8c972d7", "47d5d3cb-bffb-166c-3407-a4ccce5b6666", "b036f416-7559-f58d-35d6-63433308388f", "271d72b5-3273-cbe3-5973-e03e6b5912d3"},
    {"0a3d889b-8f99-c5f4-8544-ac835a0f188f", "09ada8dd-827c-77e3-679c-dcc26478129b", "56cc395b-a232-7931-5392-40b51eba9480", "69c51c11-85b0-766f-3a05-e1c8801e0a37", "26972ad7-e841-f115-243e-66f6f520be0d", "9a9bcdda-d0f2-dab8-5032-9ca048e1d68e"},
    {"73a0e134-8ecc-8cb7-a6fa-73768635c559", "24c29cfd-b072-1327-ef57-24eb05664bec", "ba6aa331-24fa-4445-9703-e4deba046bd4", "054a6e82-d6cf-1e89-2489-32c8943dd22c", "14777761-3488-9cfc-848e-7a75a180ffa6", "12a94143-0197-9f7d-fd75-d1f07e0a77a7"},
    {"f7672622-3122-70f0-55a1-4140a738a0f7", "dbd2095a-b921-19f8-cdd1-54e046c70dc1", "fa8c50cd-8189-08bc-c40d-7a6f86244cbd", "d65dc2e2-3b34-f3a9-d1b9-ba1c699f3503", "bd4ad0cd-7c63-c9f0-3f29-5a47ddd3a558", "5913d151-47ee-a6db-efd9-94482251ae60"},
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