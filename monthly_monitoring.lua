--[[
��������
    monthly_monitoring

��������
	������ �� QLUA, ������� ��� � �����, �������� 15 ����� ��������� � Telegram-����� ���������, 
	�� ������� �����, ������� � ���� ������ ���� � ��������. 
	���� 15-� ����� ���������� �� ��������, �� ���������� � �����������.
	
	� ������ 1.0.1 �������� ��� ����������. 
������
    1.0.1

�����������
    ������ ������ (https://t.me/ruslan_mashkin )

���� ��������
    06.11.2023

]]--
agent = "monthly_monitoring"                 -- �������� �������. 
is_running = true                            -- ���� ��� ������ ������������ �����. 
reporting_day = 15                           -- ���� ������, � ������� ��������� �����. 
reporting_hour = 13                          -- ���, � ������� ��������� �����. 
file_name = agent.."_month.txt"              -- ��� ����� ��� ���������� �������� ������. 
telegram_module = require("telegram_module") -- ����������� ������ ��� ������ � ���������. 


function OnStop()
--[[
��������
    ���������� ������� OnStop()

��������
    ������ ���������� ���������� ��� ��������� ��������� ������ �� ��������� QUIK.

���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������.
]]--
    is_running = false                        -- ������������� ���� ������ ������� ��� false
	return 500                                -- ������ ���?����
end

function main()
--[[
��������
    ������� ������� ������� - main()

��������
	� ����������� ����� ��������� ��� �������, 
	����������� ��� ������������ ������. 
	��������� ����� � ���������� � ��������. 
���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������
]]--
	
	local filename = file_name                                                  
	if not fileExists(filename) then                                                -- ���� �� ���� ��� ���������� ������ ������ �� ����������, 
		createFile(filename, "0")                                                   --   �� ������� ���.
	end
	while is_running do                                                             -- ����������� ����
		local month = tonumber(getTodayMonth())                                     -- �������� ������� ����� � ���� �����. 
		local month_day = tonumber(getTodayMonthDay())                              -- �������� ������� ���� ������ � ���� �����. 
		local weeks_day = tonumber(getTodayWeeksDay())                              -- �������� ������� ���� ������ � ���� �����. 
		if weeks_day > 0 and weeks_day < 6 then                                     -- ���� ������ ���
			if (month_day >= reporting_day) then                                    -- ���� ���� ���������� ��� ������ ��� ������
				if month ~= tonumber(readFile(filename)) then                       -- ���� ����� �������� ������ �� ��������� � ������� � �����.
					if reporting_hour == getCurrentHour() then                      -- ���� ��� ���������� ��� ������. 
						local telegram_message = ""
						local security_paper_list =  getSecurityPaperList()         -- �������� ������ �����, ����������� � ��������. 
						if #security_paper_list > 0 then                            -- ���� ������ �� ������, �� ��������� ���������. 
							telegram_message = "� ����� �������� ��������� ��������� �����:"
							for key, value in pairs(security_paper_list) do         -- 
								telegram_message = telegram_message..","..value
							end
						else
							telegram_message = "� ����� �������� ��� �����."
						end
						writeFile(filename, month)                                  -- ���������� ����� ������ � ����. 
						sendMessage(telegram_message)                               -- ���������� ��������� � ��������. 
						--message("��������� ����� � ��������.")
					end
				end
			end
		end
		sleep(60000)
	end
end

function fileExists(filename)
--[[
��������
    fileExists - ������� ��� �������� ������������� �����.

��������
    ������ ������� ���������, ���������� �� ���� � ��������� ������.

���������
    filename (string) - ��� �����, ��� �������� ����� ��������� �������������.

������������ ��������
    boolean - ���������� true, ���� ���� ����������, � false � ��������� ������.
]]
	local file = io.open(filename, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

function createFile(filename, content)
--[[
��������
    createFile - ������� ��� �������� �����.

��������
    ������ ������� ������� ���� � ��������� ������.

���������
    filename (string) - ��� �����, ������� ����� �������.
    content (string) - ���������� ��� �����. 

������������ ��������
    boolean - ���������� true, ���� ���� ������� ������, � false � ��������� ������.
]]
	local file = io.open(filename, "w")
	if file then
		writeFile(filename, content)
		file:close()
		return true
	else
		message("������ ��� �������� �����")
		return false
	end
end

function readFile(filename)
--[[
��������
    readFile - ������� ��� ������ ����������� �����.

��������
    ������ ������� ��������� ���������� ����� � ��������� ������.

���������
    filename (string) - ��� �����, ���������� �������� ����� �������.

������������ ��������
    string - ���������� ����� � ���� ������. ���� ���� �� ������, ������������ nil.
]]
	local file = io.open(filename, "r")
	if file then
		local content = file:read()
		file:close()
		return content
	else
		return nil
	end
end

function writeFile(filename, content)
--[[
��������
    writeFile - ������� ��� ������ ����������� � ����.

��������
    ������ ������� ���������� ��������� ���������� � ���� � ��������� ������.
    ���� ���� �� ����������, �� ����� ������.

���������
    filename (string) - ��� �����, � ������� ����� �������� ����������.
    content (string) - ����������, ������� ����� �������� � ����.

������������ ��������
    boolean - true, ���� ������ � ���� ������ �������, false - � ��������� ������.
]]
  local file = io.open(filename, "w")
  if file then
    file:write(content)
    file:close()
    return true
  else
    return false
  end
end

function getTodayMonth() -- int
--[[
��������
  getTodayMonth - ��������� �������� ������ � ��������� ������� 

��������
  ������� getTodayMonth ���������� ������� ����� � ��������� �������

���������
  �����������.

������������ ��������
  ����� - �����
]]--

	return tonumber(os.date("%m")) 
end


function getTodayMonthDay() -- int
--[[
��������
  getTodayMonthDay - ��������� �������� ����� ������ � ��������� ������� 

��������
  ������� getTodayMonthDay ���������� ������� ����� ������ � ��������� �������

���������
  �����������.

������������ ��������
  ����� - ������� ����� ������
]]--

	return tonumber(os.date("%d")) 
end

function getTodayWeeksDay() -- int
--[[
��������
  getTodayWeeksDay - ��������� �������� ��� ������ 

��������
  ������� getTodayWeeksDay ���������� ������� ���� ������ � ���� �����. 

���������
  �����������.

������������ ��������
  ����� - ������� ���� ������. 
]]--

	return tonumber(os.date("%w")) 
end

function getCurrentHour() -- int
--[[
��������
  getCurrentHour - ��������� ���� 

��������
  ������� getCurrentHour ���������� ������� ��� � ���� �����. 

���������
  �����������.

������������ ��������
  ����� - ������� ���.
]]--

	return tonumber(os.date("%H")) 
end


function getSecurityPaperList() -- table
--[[
��������
  getSecurityPaperList - ��������� ������ ������ �����. 

��������
  ������� getSecurityPaperList ������� � ���������� ������ ������ �����.

���������
  �����������.

������������ ��������
  table - ������ ������ �����
]]--
	local list = {}
	for i = 0,getNumberOf("depo_limits") - 1 do
	
		if getItem("depo_limits",i).limit_kind == 2 then
			local sec_code = getItem("depo_limits",i).sec_code
			local name_sec = getNameSecurityPaper(sec_code)
			if #name_sec > 0 then
				table.insert(list, name_sec)
			end
		end
	end
	return list
end

function getNameSecurityPaper(sec) -- str
--[[
��������
  getNameSecurityPaper - ��������� �������� �����. 

��������
  ������� getNameSecurityPaper ���������� ������ ��� ������.

���������
  sec - ��� �����������.

������������ ��������
  ������ ���������� ��� �����
]]--
-- ���� ������ �������� �������� ���������
	local sec_name = getParamEx("TQBR", sec, "LONGNAME").param_image
	sec_name = sec_name:gsub('"','')
	return sec_name
end

function OpenPrice(class, sec) -- number
--[[
��������
  OpenPrice - ��������� ���� ����������� �� ������ ���.

��������
  ������� OpenPrice ���������� ���� ����������� �� ������ ���.

���������
  class - ��� ������
  sec - ��� �����������

������������ ��������
  ����� - ���� ����������� �� ������ ���. 
]]--

	return tonumber(getParamEx(class, sec, "OPEN").param_value)
end

function sendMessage(mes)
--[[
��������
  sendMessage - �������� ��������� � ��������. 

��������
  ������� sendMessage ���������� ��������� � Telegram, ��������� API Key � Chat ID, ��������� � ����� ������������ "config.txt".

���������
  mes - ��������� ��� ��������

������������ ��������
    boolean - true, ���� ��������� ����������, false - � ��������� ������.
]]--
	local file = io.open("config.txt", "r") -- ��������� ���� �� ������. 
	-- ���������, ������� �� ������� ����
	if not file then
		message("Error: �� ������� ������� ���� ������������. ")
		return false
	end

	-- ������ �������� API Key �� �����
	local telegram_API_Key = file:read()

	-- ������ �������� Chat ID �� �����
	local telegram_Chat_ID = file:read()

	-- ���������, ��� ��� �������� ������� �������. 
	if not telegram_API_Key or not telegram_Chat_ID then
		message("Error: �������� �������� � ����� ������������. ")
		return false
	end

	local telegram_Chat_message = mes
	--message(telegram_Chat_message)
	-- ���������� ������� �� ������ ��� �������� ��������� � Telegram
	telegram_module.sendTelegramMessage(telegram_API_Key, telegram_Chat_ID, telegram_Chat_message)

	file:close() -- ��������� ����.  
	return true
end
