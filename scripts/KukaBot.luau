local BASE_POS: vector = vector(0.000000, -0.048218, 0.371338)

local JOINT_OFFSETS: { vector } = {
    vector(-0.15262, -0.45342, 0.18189),
    vector( 0.24921, -0.00006, 0.99340),
    vector(-0.09659, -1.02815, -0.00537),
    vector(-0.00865, -0.07277, 0.00000),
}

local DAMPING: number = 0.35

local LIMITS: { { number } } = {
    { -180, 180 }, -- base
    { -60,   90 }, -- upper
    { -90,   40 }, -- lower
    { -180, 180 }, -- wrist
    { -90,   90 }, -- hand
}

local function forwardKinematics(angles: { number })
    local joints = {}
    local axes = {}

    local pos = BASE_POS
    local rot = ll.Euler2Rot(vector(0,0,angles[1]) * DEG_TO_RAD)

    joints[1] = pos
    axes[1] = ll.Rot2Up(rot)     -- base Z

    -- Upper arm
    pos += JOINT_OFFSETS[1] * rot
    rot = ll.Euler2Rot(vector(angles[2],0,0) * DEG_TO_RAD) * rot
    joints[2] = pos
    axes[2] = ll.Rot2Fwd(rot)    -- X

    -- Lower arm
    pos += JOINT_OFFSETS[2] * rot
    rot = ll.Euler2Rot(vector(angles[3],0,0) * DEG_TO_RAD) * rot
    joints[3] = pos
    axes[3] = ll.Rot2Fwd(rot)    -- X

    -- Wrist
    pos += JOINT_OFFSETS[3] * rot
    rot = ll.Euler2Rot(vector(0,angles[4],0) * DEG_TO_RAD) * rot
    joints[4] = pos
    axes[4] = ll.Rot2Left(rot)   -- Y

    -- Hand
    pos += JOINT_OFFSETS[4] * rot
    joints[5] = pos
    axes[5] = ll.Rot2Fwd(rot)

    return joints, axes
end

local function solveIK(angles: { number }, target: vector, iterations: number)
    iterations = iterations or 25

    for iter = 1, iterations do
        for i = 1, 4 do
            local joints, axes = forwardKinematics(angles)
            local jointPos = joints[i]
            local endPos = joints[5]

            local toEnd = endPos - jointPos
            local toTarget = target - jointPos

            if vector.magnitude(toEnd) < 0.001 or vector.magnitude(toTarget) < 0.001 then
                continue
            end

            toEnd = vector.normalize(toEnd)
            toTarget = vector.normalize(toTarget)

            local axis = vector.normalize(axes[i])

            -- Project onto rotation plane
            toEnd -= axis * (toEnd * axis)
            toTarget -= axis * (toTarget * axis)

            if vector.magnitude(toEnd) < 0.0001 or vector.magnitude(toTarget) < 0.0001 then
                continue
            end

            toEnd = vector.normalize(toEnd)
            toTarget = vector.normalize(toTarget)

            local cosang = math.clamp(vector.dot(toEnd,toTarget), -1, 1)
            local ang = ll.Acos(cosang)

            local sign = vector.dot((toEnd % toTarget), axis) < 0 and -1 or 1
            local delta = ang * sign * RAD_TO_DEG * DAMPING

            angles[i] += delta
            if i ~= 1 then
                angles[i] = math.clamp(angles[i], LIMITS[i][1], LIMITS[i][2])
            end
        end

        if vector.magnitude(forwardKinematics(angles)[5] - target) < 0.01 then
            break
        end
    end

    return angles
end

-- Set armature position
local function setArmParams(rot1: number, rot2: number, rot3: number, rot4: number, rot5: number)
    local params = {}

    local pos = vector(0.000000, -0.048218, 0.371338)
    local rot = ll.Euler2Rot(vector(0, 0, rot1) * DEG_TO_RAD)
    table.move({
        PRIM_LINK_TARGET, 2,
        PRIM_POS_LOCAL, pos,
        PRIM_ROT_LOCAL, rot
    }, 1, 6, #params + 1, params)
    
    pos = pos + vector(-0.15262, -0.45342, 0.18189) * rot
    rot = ll.Euler2Rot(vector(math.clamp(rot2, -60, 90), 0, 0)*DEG_TO_RAD) * rot
    table.move({
        PRIM_LINK_TARGET, 3,
        PRIM_POS_LOCAL, pos,
        PRIM_ROT_LOCAL, rot
    }, 1, 6, #params + 1, params)
    
    pos = pos + vector(0.24921, -0.00006, 0.99340) * rot;
    rot = ll.Euler2Rot(vector(math.clamp(rot3, -90, 40), 0, 0) * DEG_TO_RAD) * rot
    table.move({
        PRIM_LINK_TARGET, 4,
        PRIM_POS_LOCAL, pos,
        PRIM_ROT_LOCAL, rot
    }, 1, 6, #params + 1, params)

    pos = pos + vector(-0.09659, -1.02815, -0.00537) * rot
    rot = ll.Euler2Rot(vector(0, rot4, 0) * DEG_TO_RAD) * rot;
    table.move({
        PRIM_LINK_TARGET, 5,
        PRIM_POS_LOCAL, pos,
        PRIM_ROT_LOCAL, rot
    }, 1, 6, #params + 1, params)
    
    pos = pos + vector(-0.00865, -0.07277, 0.00000) * rot
    rot = ll.Euler2Rot(vector(math.clamp(rot5, -90, 90), 0, 0) * DEG_TO_RAD) * rot
    table.move({
        PRIM_LINK_TARGET, 6,
        PRIM_POS_LOCAL, pos,
        PRIM_ROT_LOCAL, rot
    }, 1, 6, #params + 1, params)
    
    ll.SetLinkPrimitiveParamsFast(0, params)
end

local angles = {0, 0, 0, 0, 0}
setArmParams(0, 0, 0, 0, 0)

LLTimers:every(1 / 45.0, function()
    local rootRot = ll.GetRot()
    local target = ll.GetObjectDetails(touuid("d366c212-2c56-bd1c-f157-1b60f0dd0e0a"), {OBJECT_POS})[1]
    local localTarget = (target - ll.GetPos()) / rootRot
    angles = solveIK(angles, localTarget, 30)

    
    setArmParams(angles[1], angles[2], angles[3], angles[4], angles[5])
end)