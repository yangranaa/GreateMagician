if my_event == nil then
	my_event = class({})
end

my_event.listeners = {}

function my_event.Broadcaster(eventName, ...)
	if my_event.listeners[eventName] then
		for handle, removeOnExc in pairs(my_event.listeners[eventName]) do
			handle(...)
			if removeOnExc == 1 then
				my_event.listeners[eventName][handle] = nil
			end
		end
	end
end

function my_event.RegisterListener(eventName, handle, removeOnExc)
	if my_event.listeners[eventName] == nil then
		my_event.listeners[eventName] = {}
	end
	my_event.listeners[eventName][handle] = removeOnExc and 1 or 0
end

function my_event.UnregisterListener(eventName, handle)
	if my_event.listeners[eventName][handle] then
		my_event.listeners[eventName][handle] = nil
	end
end