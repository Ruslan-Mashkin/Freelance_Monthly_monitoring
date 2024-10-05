--[[
НАЗВАНИЕ
    monthly_monitoring

ОПИСАНИЕ
	Скрипт на QLUA, который раз в месяц, например 15 числа выгружает в Telegram-канал сообщение, 
	со списком акций, которые в этот момент есть в портфеле. 
	Если 15-е число приходится на выходные, то отправляет в понедельник.
	
	В версии 1.0.1 добавлен час отчетности. 
	В версии 1.0.2 изменен способ вывода отчета.  
	В версии 1.0.3 переделан формат вывода отчета.   

ВЕРСИЯ
    1.0.3

РАЗРАБОТЧИК
    Машкин Руслан (https://t.me/ruslan_mashkin )

Дата создания
    06.11.2023

]]--
agent = "monthly_monitoring"                 -- Название скрипта. 
is_running = true                            -- флаг для работы бесконечного цикла. 
reporting_day = 15                           -- день месяца, в который создается отчет. 
reporting_hour = 13                          -- час, в который создается отчет. 
file_name = agent.."_month.txt"              -- имя файла для сохранения текущего месяца. 
telegram_module = require("telegram_module") -- подключение модуля для работы с Телеграмм. 


function OnStop()
--[[
НАЗВАНИЕ
    Обработчик события OnStop()

ОПИСАНИЕ
    Данный обработчик вызывается при остановке торгового робота на платформе QUIK.

ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений.
]]--
    is_running = false                        -- Устанавливаем флаг работы скрипта как false
	return 500                                -- задаем таи?маут
end

function main()
--[[
НАЗВАНИЕ
    Главная функция скрипта - main()

ОПИСАНИЕ
	В бесконечном цикле проверяет все условия, 
	необходимые для формирования отчета. 
	Формирует отчет и отправляет в телеграм. 
ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений
]]--
	
	local filename = file_name                                                  
	if not fileExists(filename) then                                                -- Есть ли файл для сохранения номера месяца не существует, 
		createFile(filename, "0")                                                   --   то создаем его.
	end
	while is_running do                                                             -- Безконечный цикл
		local month = tonumber(getTodayMonth())                                     -- Получаем текущий месяц в виде числа. 
		local month_day = tonumber(getTodayMonthDay())                              -- Получаем текущий день месяца в виде числа. 
		local weeks_day = tonumber(getTodayWeeksDay())                              -- Получаем текущий день недели в виде числа. 
		if weeks_day >= 0 and weeks_day <= 6 then                                     -- Если будние дни
			if (month_day >= reporting_day) then                                    -- Если день отчетности уже настал или прошёл
				if month ~= tonumber(readFile(filename)) then                       -- Если номер текущего месяца не совпадает с записью в файле.
					if reporting_hour == getCurrentHour() then                      -- Если час отчетности уже настал. 
						local telegram_message = ""
						local security_paper_list =  getSecurityPaperList()         -- Получаем список акций, находящихся в портфеле. 
						if #security_paper_list > 0 then                            -- Если список не пустой, то формируем сообщение. 
							telegram_message = "В вашем портфеле находятся следующие акции:\n"
							
							for key, value in pairs(security_paper_list) do         -- 
								telegram_message = telegram_message .. value .. "\n"
							end
						else
							telegram_message = "В вашем портфеле нет акций."
						end
							sendMessage(telegram_message)                           -- Отправляем сообщение в телеграм. 
						
						writeFile(filename, month)                                  -- Записываем номер месяца в файл. 
						--message(telegram_message)
					end
				end
			end
		end
		sleep(60000)
	end
end

function fileExists(filename)
--[[
НАЗВАНИЕ
    fileExists - функция для проверки существования файла.

ОПИСАНИЕ
    Данная функция проверяет, существует ли файл с указанным именем.

ПАРАМЕТРЫ
    filename (string) - имя файла, для которого нужно проверить существование.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - Возвращает true, если файл существует, и false в противном случае.
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
НАЗВАНИЕ
    createFile - функция для создания файла.

ОПИСАНИЕ
    Данная функция создает файл с указанным именем.

ПАРАМЕТРЫ
    filename (string) - имя файла, который нужно создать.
    content (string) - содержимое для файла. 

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - Возвращает true, если файл успешно создан, и false в противном случае.
]]
	local file = io.open(filename, "w")
	if file then
		writeFile(filename, content)
		file:close()
		return true
	else
		message("Ошибка при создании файла")
		return false
	end
end

function readFile(filename)
--[[
НАЗВАНИЕ
    readFile - функция для чтения содержимого файла.

ОПИСАНИЕ
    Данная функция считывает содержимое файла с указанным именем.

ПАРАМЕТРЫ
    filename (string) - имя файла, содержимое которого нужно считать.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    string - Содержимое файла в виде строки. Если файл не найден, возвращается nil.
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
НАЗВАНИЕ
    writeFile - функция для записи содержимого в файл.

ОПИСАНИЕ
    Данная функция записывает указанное содержимое в файл с указанным именем.
    Если файл не существует, он будет создан.

ПАРАМЕТРЫ
    filename (string) - имя файла, в который нужно записать содержимое.
    content (string) - содержимое, которое нужно записать в файл.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - true, если запись в файл прошла успешно, false - в противном случае.
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

function deleteFile(filename)
--[[
НАЗВАНИЕ
    deleteFile - функция для удаления файла. 

ОПИСАНИЕ
    Данная функция удаляет файл с указанным именем.

ПАРАМЕТРЫ
    filename (string) - имя файла, который нужно удалить.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - true, если файл удален успешно, false - в противном случае.
]]
	os.remove(filename)

	local file = io.open(filename, "r")
	if file then
		return false
	else
		return true
	end 

end

function Execute(command)
--[[
НАЗВАНИЕ
    Execute - функция для выполнения команд в командной строке.  

ОПИСАНИЕ
    Данная функция выполняет команды в командной строке. 

ПАРАМЕТРЫ
    command (string) - команда, которую нужно выполнить.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - true, если выполнение команды прошло успешно, false - в противном случае.
]]
	local result = os.execute(tostring(command))
	return result == 0
end

function getTodayMonth() -- int
--[[
НАЗВАНИЕ
  getTodayMonth - Получение текущего месяца в системном времени 

ОПИСАНИЕ
  Функция getTodayMonth возвращает текущий месяц в системном времени

ПАРАМЕТРЫ
  Отсутствуют.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  число - месяц
]]--

	return tonumber(os.date("%m")) 
end


function getTodayMonthDay() -- int
--[[
НАЗВАНИЕ
  getTodayMonthDay - Получение текущего числа месяца в системном времени 

ОПИСАНИЕ
  Функция getTodayMonthDay возвращает текущее число месяца в системном времени

ПАРАМЕТРЫ
  Отсутствуют.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  число - текущее число месяца
]]--

	return tonumber(os.date("%d")) 
end

function getTodayWeeksDay() -- int
--[[
НАЗВАНИЕ
  getTodayWeeksDay - Получение текущего дня недели 

ОПИСАНИЕ
  Функция getTodayWeeksDay возвращает текущий день недели в виде числа. 

ПАРАМЕТРЫ
  Отсутствуют.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  число - текущей день недели. 
]]--

	return tonumber(os.date("%w")) 
end

function getCurrentHour() -- int
--[[
НАЗВАНИЕ
  getCurrentHour - Получение часа 

ОПИСАНИЕ
  Функция getCurrentHour возвращает текущий час в виде числа. 

ПАРАМЕТРЫ
  Отсутствуют.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  число - текущей час.
]]--

	return tonumber(os.date("%H")) 
end


function getSecurityPaperList() -- table
--[[
НАЗВАНИЕ
  getSecurityPaperList - Получение списка ценных бумаг. 

ОПИСАНИЕ
  Функция getSecurityPaperList создает и возвращает список ценных бумаг.

ПАРАМЕТРЫ
  Отсутствуют.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  table - список ценных бумаг
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
НАЗВАНИЕ
  getNameSecurityPaper - Получение названия акции. 

ОПИСАНИЕ
  Функция getNameSecurityPaper возвращает полное имя бумаги.

ПАРАМЕТРЫ
  sec - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  строка содержащая имя акции
]]--
-- Если строка окружена двойными кавычками
	local sec_name = getParamEx("TQBR", sec, "LONGNAME").param_image
	sec_name = sec_name:gsub('"','')
	return sec_name
end

function OpenPrice(class, sec) -- number
--[[
НАЗВАНИЕ
  OpenPrice - Получение цены инструмента на начало дня.

ОПИСАНИЕ
  Функция OpenPrice возвращает цену инструмента на начало дня.

ПАРАМЕТРЫ
  class - код класса
  sec - код инструмента

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  число - цена инструмента на начало дня. 
]]--

	return tonumber(getParamEx(class, sec, "OPEN").param_value)
end

function sendMessage(mes)
--[[
НАЗВАНИЕ
  sendMessage - Отправка сообщения в телеграм. 

ОПИСАНИЕ
  Функция sendMessage отправляет Сообщение в Telegram, используя API Key и Chat ID, указанные в файле конфигурации "config.txt".

ПАРАМЕТРЫ
  mes - сообщение для отправки

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - true, если сообщение отправлено, false - в противном случае.
]]--
	local file = io.open("config.txt", "r") -- Открываем файл на чтение. 
	-- Проверяем, удалось ли открыть файл
	if not file then
		message("Error: Не удалось открыть файл конфигурации. ")
		return false
	end

	-- Читаем значение API Key из файла
	local telegram_API_Key = file:read()

	-- Читаем значение Chat ID из файла
	local telegram_Chat_ID = file:read()

	-- Проверяем, что оба значения считаны успешно. 
	if not telegram_API_Key or not telegram_Chat_ID then
		message("Error: Неверное значение в файле конфигурации. ")
		return false
	end

	local telegram_Chat_message = mes
	-- Используем функцию из модуля для отправки сообщения в Telegram
	sendTelegramMessage(telegram_API_Key, telegram_Chat_ID, telegram_Chat_message)
	file:close() -- Закрываем файл.  
	return true
end

function sendTelegramMessage(API_Key, Chat_ID, m_message)
--[[ Функция sendTelegramMessage(API_Key, Chat_ID, m_message)
     Описание: Отправляет сообщение в Telegram.
     Аргументы:
         - API_Key: строка, ключ API Telegram.
         - Chat_ID: строка, идентификатор чата Telegram.
         - m_message: строка, текст сообщения.
     Возвращаемое значение: Отсутствует. 
]]
	local message_file = agent.."_messagefile.txt"
	writeFile(message_file, m_message)
	
    -- Формирование команды для запуска внешней программы telegram_sender.exe
    local program_file = ".\\sender.exe "
    local mess = '$content = Get-Content '..message_file..' -Raw\n'
    local command = mess .. program_file .. API_Key .. " " .. Chat_ID ..  " $content"
	-- Создание ps1 файла. 
	local command_file = agent.."_command_file.ps1"
	writeFile(command_file, command)
    -- Запуск команды для отправки сообщения
	local command_ps1 = "powershell -executionpolicy RemoteSigned -WindowStyle Hidden -file "..command_file
	Execute(command_ps1)
	deleteFile(message_file)
	deleteFile(command_file)
end
