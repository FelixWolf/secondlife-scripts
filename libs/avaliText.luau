local gAlphabet = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`"
local gTextureAtlas = {
    {"cde9e8f6-dc8d-4538-6e23-91fd9d26b7f2", "e919234e-68ec-289f-1eac-47c9d5885b4f", "b27f620e-29be-506d-59fa-564da579abcd", "cf1918de-a2e9-9d2d-4989-866fc473fb53", "8b7fe255-b7c7-740e-66b1-752f7b941729"},
    {"e5d093af-a49c-15da-88b5-b13c9baeb5d8", "777ac49a-c54a-df9d-ad76-de943e12efbf", "7650f0d4-aa40-cb41-9197-8f4be6b2fafb", "b4c1d77a-f277-6650-6f69-49b0f1883e1c", "0bbf0d55-fc80-6dfc-8ae4-598ad4a83213"},
    {"c5dfecac-1220-82f2-dc51-3f86c705d2ee", "426ac38c-ba33-c634-e6b7-da2b3b54d93a", "b913908d-9403-071c-9305-5264e67768d6", "1591c7b8-5bbb-cd40-b086-93ea8a32bbef", "397afa61-f26d-77e6-b11e-4ba06778eeea"},
    {"4609d805-55f6-22ab-a824-035648aa77a8", "cb98ccf6-fce0-4d89-9e67-58fea26de796", "df862b8b-33e2-cded-69e0-e97bd1105b6f", "6d716035-526f-31f2-1c60-1c29edc42c41", "1fb32bf9-ca28-58c1-3a70-e55d96d646c6"},
    {"d6d64a09-f1cb-437e-7aad-7a957b658912", "877b7aa5-6970-5d7d-2fdc-637488a3cb07", "3f3e1338-b56d-a435-78b3-e1afad50dd61", "7632dba8-07ab-b273-8bf1-dff236394e37", "2cb7c693-40c7-e7b4-7f2e-37cfad35c9ff"},
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
    u *= 1
    return {
        PRIM_TEXTURE,
        face,
        gTextureAtlas[(i1 // 15) + 1][(i2 // 16) + 1],
        vector(1/15, 1/16, 0),
        vector((-0.505 + (1/15/2)) + u, (0.5 - (1/16/2)) - v, 0),
        0
    }
end

local function getAvaliText(text: string, link: number)
    text = string.upper(text)

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
        
        -- Pad with space if only one character
        if #chunk == 1 then
            chunk = chunk .. " "
        end
        table.move(getTextAt(chunk, face), 1, 6, #result + 1, result)
        face += 1
    end

    for i = face, 8 do
        table.move(getTextAt("  ", i), 1, 6, #result + 1, result)
    end

    ll.SetLinkPrimitiveParamsFast(0, result)
end

return getAvaliText