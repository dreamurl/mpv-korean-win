-- 화질 등급·모드를 기억하는 스크립트
--
-- 왜 필요한가:
--   mpv 의 apply-profile 은 재생 중에만 유효하고 다음 실행에는 남지 않는다.
--   설정 파일을 직접 고치게 하면 "파일 만지기 어려운 사람을 위한 빌드"라는
--   전제가 무너진다. 그래서 고른 값을 작은 파일에 적어 두고 켤 때 다시
--   적용한다. 사용자는 우클릭 메뉴만 쓰면 된다.
--
-- 어디에 적히나:
--   설정 폴더의 quality-state.conf. 설치 프로그램이 처음 한 줄을 써 두고,
--   그 뒤로는 이 스크립트가 덮어쓴다.
--
--       tier = std
--       mode = a
--
-- 프로필 이름은 <등급>-<모드> 로 조립해 quality.conf 에서 찾는다.

local mp = require 'mp'
local msg = require 'mp.msg'

local STATE_PATH = mp.command_native({"expand-path", "~~/quality-state.conf"})

local TIER_ORDER = {"low", "std", "high"}
local TIER_LABEL = {
    low  = "내장 그래픽",
    std  = "보통",
    high = "고성능",
}

local MODE_ORDER = {"a", "b", "c", "aa", "bb", "ca", "off"}
local MODE_LABEL = {
    a   = "A — 1080p 애니",
    b   = "B — 720p 애니",
    c   = "C — 480p·저해상도",
    aa  = "A+A — 1080p (무거움)",
    bb  = "B+B — 720p (무거움)",
    ca  = "C+A — 저해상도 (무거움)",
    off = "끄기 (원본 그대로)",
}

-- 파일이 없거나 값이 이상할 때 쓰는 값. 설치 프로그램이 제대로 써 줬다면
-- 여기까지 오지 않는다.
local state = { tier = "std", mode = "a" }

local function is_valid(list, value)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end


---------------------------------------------------------------- 읽고 쓰기

local function load_state()
    local f = io.open(STATE_PATH, "r")
    if not f then
        msg.info("설정 파일이 없어 기본값으로 시작합니다: " .. STATE_PATH)
        return
    end

    for line in f:lines() do
        -- `tier = std` / `tier=std` / 앞뒤 공백 전부 허용. # 은 주석.
        local key, value = line:match("^%s*([%a_]+)%s*=%s*([%w%-]+)")
        if key == "tier" and is_valid(TIER_ORDER, value) then
            state.tier = value
        elseif key == "mode" and is_valid(MODE_ORDER, value) then
            state.mode = value
        end
    end
    f:close()
end

local function save_state()
    local f = io.open(STATE_PATH, "w")
    if not f then
        -- Program Files 아래에 설치하면 권한이 없을 수 있다. 저장만 실패하고
        -- 재생은 계속되어야 한다.
        msg.warn("설정을 저장하지 못했습니다: " .. STATE_PATH)
        mp.osd_message("설정을 저장하지 못했습니다 (이번 재생에만 적용됩니다)", 4)
        return
    end

    f:write("# 화질 설정. 재생 화면에서 우클릭 → [화질] 로 바꾸면 여기에 기록됩니다.\n")
    f:write("# 직접 고쳐도 됩니다.\n")
    f:write("#   tier : low(내장 그래픽) / std(보통) / high(고성능)\n")
    f:write("#   mode : a / b / c / aa / bb / ca / off\n\n")
    f:write("tier = " .. state.tier .. "\n")
    f:write("mode = " .. state.mode .. "\n")
    f:close()
end


---------------------------------------------------------------- 적용

local function apply(announce)
    local profile = (state.mode == "off") and "shaders-off"
                                           or (state.tier .. "-" .. state.mode)

    -- 없는 프로필을 부르면 mpv 가 로그에 오류만 남기고 조용히 넘어간다.
    -- 사용자에게는 "화질이 안 바뀌네" 로만 보이므로 직접 확인해 알린다.
    --
    -- mp.commandv 는 성공하면 true, 실패하면 nil 을 돌려준다. false 가
    -- 아니므로 `== false` 로 검사하면 영원히 걸리지 않는다.
    local ok = mp.commandv("apply-profile", profile)
    if not ok then
        msg.error("프로필을 찾을 수 없습니다: " .. profile)
        mp.osd_message("화질 프로필을 찾을 수 없습니다: " .. profile, 4)
        return
    end

    if announce then
        if state.mode == "off" then
            mp.osd_message("화질 보정 끔 (원본 그대로)", 2)
        else
            mp.osd_message(
                "화질: " .. MODE_LABEL[state.mode]
                .. "   [" .. TIER_LABEL[state.tier] .. "]", 2)
        end
    end
end


---------------------------------------------------------------- 메뉴에 연결

local function set_tier(tier)
    return function()
        state.tier = tier
        -- 등급만 바꿨는데 셰이더가 꺼져 있으면 바뀐 게 눈에 안 보인다.
        -- 등급을 고르는 행동은 "켜고 싶다"는 뜻으로 읽는다.
        if state.mode == "off" then state.mode = "a" end
        apply(false)
        save_state()
        mp.osd_message("내 PC 성능: " .. TIER_LABEL[tier], 2)
    end
end

local function set_mode(mode)
    return function()
        state.mode = mode
        apply(true)
        save_state()
    end
end

for _, tier in ipairs(TIER_ORDER) do
    mp.add_key_binding(nil, "set-tier-" .. tier, set_tier(tier))
end

for _, mode in ipairs(MODE_ORDER) do
    mp.add_key_binding(nil, "set-mode-" .. mode, set_mode(mode))
end

-- 지금 무엇이 적용돼 있는지 확인용.
mp.add_key_binding(nil, "show-current", function()
    mp.osd_message(
        "내 PC 성능: " .. TIER_LABEL[state.tier] .. "\n" ..
        "화질 모드: " .. MODE_LABEL[state.mode], 4)
end)


---------------------------------------------------------------- 시작

load_state()

-- 파일을 열기 전(유휴 화면)에는 셰이더를 걸 대상이 없다. 첫 파일이 열릴 때
-- 한 번 적용하고, 그 뒤로는 사용자가 바꿀 때만 적용한다.
local applied_once = false
mp.register_event("file-loaded", function()
    if applied_once then return end
    applied_once = true
    apply(false)
end)
